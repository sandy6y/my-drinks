from datetime import datetime
from typing import Optional
from uuid import UUID

from fastapi import Depends, FastAPI, HTTPException, Query, Response, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import and_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from .database import Base, engine, get_db
from .models import DrinkLog
from .schemas import LogCreate, LogResponse, LogUpdate


app = FastAPI(title="Caffeinate Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)


@app.get("/health")
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/v1/logs", response_model=list[LogResponse])
def list_logs(
    from_: Optional[datetime] = Query(default=None, alias="from"),
    to: Optional[datetime] = Query(default=None),
    limit: int = Query(default=100, ge=1, le=1000),
    db: Session = Depends(get_db),
) -> list[DrinkLog]:
    stmt = select(DrinkLog)
    filters = []

    if from_ is not None:
        filters.append(DrinkLog.time >= from_)
    if to is not None:
        filters.append(DrinkLog.time < to)

    if filters:
        stmt = stmt.where(and_(*filters))

    stmt = stmt.order_by(DrinkLog.time.desc()).limit(limit)
    return list(db.scalars(stmt).all())


@app.post("/v1/logs", response_model=LogResponse, status_code=status.HTTP_201_CREATED)
def create_log(payload: LogCreate, db: Session = Depends(get_db)) -> DrinkLog:
    log = DrinkLog(
        name=payload.name,
        time=payload.time,
        type=payload.type.value,
        size=payload.size.value,
        temperature=payload.temperature.value,
        caffeine=payload.caffeine,
        sugar=payload.sugar,
        price=payload.price,
        rating=payload.rating,
        note=payload.note,
    )
    db.add(log)

    try:
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=400, detail="Invalid log payload.") from exc

    db.refresh(log)
    return log


@app.patch("/v1/logs/{log_id}", response_model=LogResponse)
def update_log(log_id: UUID, payload: LogUpdate, db: Session = Depends(get_db)) -> DrinkLog:
    log = db.get(DrinkLog, str(log_id))
    if log is None:
        raise HTTPException(status_code=404, detail="Log not found.")

    for field, value in payload.model_dump(exclude_unset=True).items():
        if field in {"type", "size", "temperature"} and value is not None:
            setattr(log, field, value.value)
        else:
            setattr(log, field, value)

    try:
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=400, detail="Invalid log payload.") from exc

    db.refresh(log)
    return log


@app.delete("/v1/logs/{log_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_log(log_id: UUID, db: Session = Depends(get_db)) -> Response:
    log = db.get(DrinkLog, str(log_id))
    if log is None:
        raise HTTPException(status_code=404, detail="Log not found.")

    db.delete(log)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
