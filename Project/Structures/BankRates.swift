import Foundation

struct BankRate: Decodable {
    let id: Int
    let code: String
    let date: String
    let abbreviation: String
    let scale: Int
    let name: String
    let officialRate: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "Cur_ID"
        case code = "Cur_Code"
        case date = "Date"
        case abbreviation = "Cur_Abbreviation"
        case scale = "Cur_Scale"
        case name = "Cur_Name"
        case officialRate = "Cur_OfficialRate"
    }
}
