//
//  NewLogView.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import SwiftUI

struct NewLogView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: LogViewModel

    @State private var name: String = ""
    @State private var time: Date = Date()
    @State private var selectedType: DrinkType = .espresso
    @State private var selectedSize: DrinkSize = .medium
    @State private var selectedTemp: DrinkTemperature = .iced
    @State private var caffeine: String = ""
    @State private var sugar: String = ""
    @State private var price: String = ""
    @State private var rating: Int = 0
    @State private var note: String = "" 
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: Date
                    DatePicker("", selection: $time)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Divider()
                    
                    // MARK: Name
                    inputField(label: "Name (Optional)", placeholder: "", text: $name)
                    
                    Divider()
                    
                    // MARK: Type
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Coffee Type")
                        drinkTypeGrid
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // MARK: Size
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Size")
                        HStack(spacing: 8) {
                            ForEach(DrinkSize.allCases, id: \.self) { size in
                                selectableButton(label: size.rawValue.capitalized, isSelected: selectedSize == size
                                ) {
                                    selectedSize = size
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // MARK: Temperature
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Temperature")
                        HStack(spacing: 8) {
                            selectableButton(label: "🧊 Iced", isSelected: selectedTemp == .iced) {
                                selectedTemp = .iced
                            }
                            selectableButton(label: "🔥 Hot", isSelected: selectedTemp == .hot) {
                                selectedTemp = .hot
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // MARK: Caffeine
                    numberInputField(label: "Caffeine", placeholder: "mg", text: $caffeine)
                    
                    Divider()
                    
                    // MARK: Sugar
                    numberInputField(label: "Sugar", placeholder: "g", text: $sugar)
                    
                    Divider()
                    
                    // MARK: Price
                    numberInputField(label: "Price", placeholder: "Optional", text: $price)
                    
                    Divider()
                    
                    // MARK: Rating
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Rate")
                        HeartRatingView(rating: $rating)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // MARK: Note
                    VStack(alignment: .leading, spacing: 8) {
                        sectionLabel("Note")
                        TextField("Morning routine, quick grab...", text: $note, axis: .vertical)
                            .lineLimit(3...)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Add Drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss()}
                        .foregroundStyle(.brown)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {saveLog()}
                        .fontWeight(.semibold)
                        .foregroundStyle(.brown)
                }
            }
        }
    }
    
    // MARK: - Drink Type Grid
    var drinkTypeGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
            ForEach(DrinkType.allCases, id: \.self) { type in
                VStack(spacing: 6) {
                    Text(type.emoji)
                        .font(.title2)
                        .frame(width: 56, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedType == type ? Color.brown.opacity(0.15) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(selectedType == type ? Color.brown : Color.clear, lineWidth: 1.5)
                        )
                    Text(type.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .onTapGesture { selectedType = type }
            }
        }
    }

    
    // MARK: Helpers
    func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    
    func inputField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel(label)
            TextField(placeholder, text: text)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
    
    func numberInputField(label: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            sectionLabel(label)
            Spacer()
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal)
    }
    
    func selectableButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.brown : Color(.systemGray6))
                )
        }
    }

    // MARK: - Save
    func saveLog() {
        let log = Log(
            name: name,
            time: time,
            type: selectedType,
            size: selectedSize,
            temperature: selectedTemp,
            caffeine: Int(caffeine) ?? 0,
            sugar: Int(sugar) ?? 0,
            price: Double(price),
            rating: rating == 0 ? nil : rating,
            note: note.isEmpty ? nil : note
        )
        Task {
            await viewModel.createLog(log)
            dismiss()
        }
    }

    // MARK: - Heart Rating
    struct HeartRatingView: View {
        @Binding var rating: Int
        var body: some View {
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= rating ? "heart.fill" : "heart")
                        .foregroundStyle(i <= rating ? .red : Color.pink.opacity(0.3))
                        .font(.title3)
                        .onTapGesture { rating = i }
                }
            }
        }
    }
}

#Preview {
    NewLogView(viewModel: LogViewModel())
}
