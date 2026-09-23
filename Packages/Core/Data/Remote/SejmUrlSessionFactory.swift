import Foundation
import Security

public struct SejmUrlSessionFactory {
    public static func create() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 30.0

        let delegate = SejmSessionDelegate()
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}

private final class SejmSessionDelegate: NSObject, URLSessionDelegate {

    private let pinnedCertificate: SecCertificate?

    override init() {
        self.pinnedCertificate = Self.loadCertificateFromBundle()
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let pinnedCertificate = pinnedCertificate else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        SecTrustSetAnchorCertificates(serverTrust, [pinnedCertificate] as CFArray)
        SecTrustSetAnchorCertificatesOnly(serverTrust, true)

        var error: CFError?
        if SecTrustEvaluateWithError(serverTrust, &error) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("SSL Pinning failed: \(String(describing: error))")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }



    private static func loadCertificateFromBundle() -> SecCertificate? {
        guard let url = Bundle.module.url(forResource: "sejm_cert", withExtension: "pem"),
              let pemString = try? String(contentsOf: url, encoding: .utf8) else {
            print("Nie znaleziono pliku sejm_cert.pem w Resources paczki Data")
            return nil
        }

        let lines = pemString.components(separatedBy: .newlines)
        let base64String = lines
            .filter { !$0.hasPrefix("-----") }
            .joined()

        guard let certData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
              let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
            print("Nie udało się sparsować binarnego DER z pliku PEM")
            return nil
        }

        return certificate
    }
}
