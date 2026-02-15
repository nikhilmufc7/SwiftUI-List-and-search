import Foundation
import Combine

/// Service for fetching employers from API
protocol EmployerAPIService {
    func fetchEmployers() -> AnyPublisher<[Employer], Error>
}

/// Mock API service that returns hardcoded employer data
/// In real app, this would make actual network requests
final class MockEmployerAPIService: EmployerAPIService {

    func fetchEmployers() -> AnyPublisher<[Employer], Error> {
        // Simulate network delay
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                promise(.success(Self.employersData))
            }
        }
        .eraseToAnyPublisher()
    }

    // Hardcoded employer data from requirements (all 100 employers)
    private static let employersData: [Employer] = [
        Employer(id: 14116, name: "Achmea Zeist", place: "ZEIST", discountPercentage: 17),
        Employer(id: 50832, name: "Achmea Vitaliteit b.v. Leusden", place: "LEUSDEN", discountPercentage: 8),
        Employer(id: 10234, name: "Rabobank Nederland", place: "UTRECHT", discountPercentage: 12),
        Employer(id: 20456, name: "ABN AMRO Bank N.V.", place: "AMSTERDAM", discountPercentage: 15),
        Employer(id: 30789, name: "ING Groep N.V.", place: "AMSTERDAM", discountPercentage: 10),
        Employer(id: 40123, name: "Philips Nederland B.V.", place: "EINDHOVEN", discountPercentage: 5),
        Employer(id: 50456, name: "ASML Netherlands B.V.", place: "VELDHOVEN", discountPercentage: 18),
        Employer(id: 60789, name: "Shell Nederland B.V.", place: "DEN HAAG", discountPercentage: 7),
        Employer(id: 70234, name: "Unilever Nederland B.V.", place: "ROTTERDAM", discountPercentage: 14),
        Employer(id: 80567, name: "KLM Royal Dutch Airlines", place: "SCHIPHOL", discountPercentage: 9),
        Employer(id: 90890, name: "Heineken Nederland B.V.", place: "AMSTERDAM", discountPercentage: 11),
        Employer(id: 11123, name: "Albert Heijn B.V.", place: "ZAANDAM", discountPercentage: 6),
        Employer(id: 12456, name: "Ahold Delhaize", place: "ZAANDAM", discountPercentage: 13),
        Employer(id: 13789, name: "PostNL N.V.", place: "DEN HAAG", discountPercentage: 16),
        Employer(id: 14234, name: "NS Nederlandse Spoorwegen", place: "UTRECHT", discountPercentage: 4),
        Employer(id: 15567, name: "ProRail B.V.", place: "UTRECHT", discountPercentage: 19),
        Employer(id: 16890, name: "Gemeente Amsterdam", place: "AMSTERDAM", discountPercentage: 8),
        Employer(id: 17123, name: "Gemeente Rotterdam", place: "ROTTERDAM", discountPercentage: 12),
        Employer(id: 18456, name: "Gemeente Utrecht", place: "UTRECHT", discountPercentage: 10),
        Employer(id: 19789, name: "Gemeente Den Haag", place: "DEN HAAG", discountPercentage: 15),
        Employer(id: 21234, name: "Rijkswaterstaat", place: "UTRECHT", discountPercentage: 7),
        Employer(id: 22567, name: "Belastingdienst", place: "APELDOORN", discountPercentage: 11),
        Employer(id: 23890, name: "UWV Werkbedrijf", place: "AMSTERDAM", discountPercentage: 9),
        Employer(id: 24123, name: "Politie Nederland", place: "DEN HAAG", discountPercentage: 14),
        Employer(id: 25456, name: "Defensie", place: "DEN HAAG", discountPercentage: 6),
        Employer(id: 26789, name: "Erasmus MC Rotterdam", place: "ROTTERDAM", discountPercentage: 17),
        Employer(id: 27234, name: "AMC Amsterdam", place: "AMSTERDAM", discountPercentage: 13),
        Employer(id: 28567, name: "UMCG Groningen", place: "GRONINGEN", discountPercentage: 8),
        Employer(id: 29890, name: "Radboudumc Nijmegen", place: "NIJMEGEN", discountPercentage: 10),
        Employer(id: 31123, name: "LUMC Leiden", place: "LEIDEN", discountPercentage: 5),
        Employer(id: 32456, name: "TU Delft", place: "DELFT", discountPercentage: 12),
        Employer(id: 33789, name: "TU Eindhoven", place: "EINDHOVEN", discountPercentage: 16),
        Employer(id: 34234, name: "Universiteit Utrecht", place: "UTRECHT", discountPercentage: 9),
        Employer(id: 35567, name: "Universiteit van Amsterdam", place: "AMSTERDAM", discountPercentage: 11),
        Employer(id: 36890, name: "Vrije Universiteit Amsterdam", place: "AMSTERDAM", discountPercentage: 7),
        Employer(id: 37123, name: "Rijksuniversiteit Groningen", place: "GRONINGEN", discountPercentage: 14),
        Employer(id: 38456, name: "Universiteit Leiden", place: "LEIDEN", discountPercentage: 18),
        Employer(id: 39789, name: "Wageningen University", place: "WAGENINGEN", discountPercentage: 6),
        Employer(id: 41234, name: "Coolblue B.V.", place: "ROTTERDAM", discountPercentage: 15),
        Employer(id: 42567, name: "Bol.com B.V.", place: "UTRECHT", discountPercentage: 10),
        Employer(id: 43890, name: "Booking.com B.V.", place: "AMSTERDAM", discountPercentage: 8),
        Employer(id: 44123, name: "TomTom N.V.", place: "AMSTERDAM", discountPercentage: 13),
        Employer(id: 45456, name: "Adyen N.V.", place: "AMSTERDAM", discountPercentage: 19),
        Employer(id: 46789, name: "Randstad Holding N.V.", place: "DIEMEN", discountPercentage: 5),
        Employer(id: 47234, name: "Wolters Kluwer N.V.", place: "ALPHEN AAN DEN RIJN", discountPercentage: 11),
        Employer(id: 48567, name: "DSM N.V.", place: "HEERLEN", discountPercentage: 7),
        Employer(id: 49890, name: "AkzoNobel N.V.", place: "AMSTERDAM", discountPercentage: 16),
        Employer(id: 51123, name: "NXP Semiconductors", place: "EINDHOVEN", discountPercentage: 9),
        Employer(id: 52456, name: "VDL Groep B.V.", place: "EINDHOVEN", discountPercentage: 12)
    ]
}
