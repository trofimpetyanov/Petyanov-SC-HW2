struct AnimalSpecies: Codable, Equatable, Hashable {
    let value: String

    init?(_ value: String) {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            return nil 
        }
        self.value = trimmedValue
    }
} 