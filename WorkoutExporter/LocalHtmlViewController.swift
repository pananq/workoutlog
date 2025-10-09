import UIKit
import WebKit
import Photos

class LocalHtmlViewController: UIViewController, WKScriptMessageHandler {
    
    private var webView: WKWebView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLocalHTML()
    }
    
    private func setupUI() {
        title = "运动热力图"
        view.backgroundColor = .systemBackground
        
        // 配置WKWebView
        let webConfiguration = WKWebViewConfiguration()
        // 允许JavaScript执行
        webConfiguration.preferences.javaScriptEnabled = true
        // 允许内联媒体播放
        webConfiguration.allowsInlineMediaPlayback = true
        
        // 添加消息处理器
        webConfiguration.userContentController.add(self, name: "saveImage")
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // 配置活动指示器
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 添加导航栏按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshWebView)
        )
    }
    
    private func loadLocalHTML() {
        activityIndicator.startAnimating()
        
        // 获取本地HTML文件路径
        guard let htmlPath = Bundle.main.path(forResource: "workout", ofType: "html") else {
            showAlert(title: "错误", message: "找不到workout.html文件，请确保文件已添加到项目Bundle中")
            activityIndicator.stopAnimating()
            return
        }
        
        let htmlURL = URL(fileURLWithPath: htmlPath)
        let folderURL = htmlURL.deletingLastPathComponent()
        
        // 使用loadFileURL方法加载本地HTML文件，并允许访问同目录下的资源文件
        webView.loadFileURL(htmlURL, allowingReadAccessTo: folderURL)
    }
    
    @objc private func refreshWebView() {
        loadLocalHTML()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "saveImage" {
            guard let messageBody = message.body as? [String: Any],
                  let imageDataString = messageBody["imageData"] as? String,
                  let filename = messageBody["filename"] as? String else {
                print("无效的消息格式")
                return
            }
            
            saveImageToPhotoLibrary(imageDataString: imageDataString, filename: filename)
        }
    }
    
    private func saveImageToPhotoLibrary(imageDataString: String, filename: String) {
        // 移除data:image/png;base64,前缀
        let base64String = imageDataString.replacingOccurrences(of: "data:image/png;base64,", with: "")
        
        guard let imageData = Data(base64Encoded: base64String),
              let image = UIImage(data: imageData) else {
            showAlert(title: "错误", message: "无法处理图片数据")
            return
        }
        
        // 检查相册访问权限
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.performSaveToPhotoLibrary(image: image, filename: filename)
                case .denied, .restricted:
                    self?.showAlert(title: "权限被拒绝", message: "请在设置中允许访问相册权限")
                case .notDetermined:
                    self?.showAlert(title: "权限未确定", message: "请重试并允许访问相册权限")
                @unknown default:
                    self?.showAlert(title: "未知错误", message: "无法获取相册权限")
                }
            }
        }
    }
    
    private func performSaveToPhotoLibrary(image: UIImage, filename: String) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            request.creationDate = Date()
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.showAlert(title: "保存成功", message: "图片已保存到相册")
                } else {
                    let errorMessage = error?.localizedDescription ?? "未知错误"
                    self?.showAlert(title: "保存失败", message: "无法保存到相册: \(errorMessage)")
                }
            }
        }
    }
}

extension LocalHtmlViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        print("HTML文件加载完成")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showAlert(title: "加载失败", message: "无法加载HTML文件: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showAlert(title: "加载失败", message: "无法加载HTML文件: \(error.localizedDescription)")
    }
}