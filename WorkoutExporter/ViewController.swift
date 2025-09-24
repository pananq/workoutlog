import UIKit
import HealthKit

class ViewController: UIViewController {
    
    private let healthManager = HealthManager()
    
    // UI组件
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "健身记录导出"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "将您的Apple Health健身记录导出为CSV文件"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 时间范围选择器
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "开始日期:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.maximumDate = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "结束日期:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.date = Date()
        picker.maximumDate = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let exportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("导出CSV", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "准备就绪"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(startDateLabel)
        view.addSubview(startDatePicker)
        view.addSubview(endDateLabel)
        view.addSubview(endDatePicker)
        view.addSubview(exportButton)
        view.addSubview(statusLabel)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startDateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            startDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startDateLabel.widthAnchor.constraint(equalToConstant: 80),
            
            startDatePicker.centerYAnchor.constraint(equalTo: startDateLabel.centerYAnchor),
            startDatePicker.leadingAnchor.constraint(equalTo: startDateLabel.trailingAnchor, constant: 10),
            startDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            endDateLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 20),
            endDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            endDateLabel.widthAnchor.constraint(equalToConstant: 80),
            
            endDatePicker.centerYAnchor.constraint(equalTo: endDateLabel.centerYAnchor),
            endDatePicker.leadingAnchor.constraint(equalTo: endDateLabel.trailingAnchor, constant: 10),
            endDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            exportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exportButton.topAnchor.constraint(equalTo: endDateLabel.bottomAnchor, constant: 40),
            exportButton.widthAnchor.constraint(equalToConstant: 200),
            exportButton.heightAnchor.constraint(equalToConstant: 50),
            
            statusLabel.topAnchor.constraint(equalTo: exportButton.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20)
        ])
        
        // 设置默认日期范围（最近一年）
        let calendar = Calendar.current
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        startDatePicker.date = oneYearAgo
    }
    
    private func setupActions() {
        exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
    }
    
    @objc private func exportButtonTapped() {
        // 检查HealthKit授权状态
        guard HKHealthStore.isHealthDataAvailable() else {
            showAlert(title: "错误", message: "HealthKit不可用")
            return
        }
        
        let healthStore = HKHealthStore()
        let workoutType = HKObjectType.workoutType()
        
        healthStore.getRequestStatusForAuthorization(toShare: [], read: [workoutType]) { status, error in
            DispatchQueue.main.async {
                if status == .unnecessary {
                    self.startExportProcess()
                } else {
                    self.showAlert(title: "需要授权", message: "请前往设置 > 健康 > 数据访问与设备，授予此应用访问健身数据的权限")
                }
            }
        }
    }
    
    private func startExportProcess() {
        activityIndicator.startAnimating()
        statusLabel.text = "正在导出健身数据..."
        exportButton.isEnabled = false
        
        // 获取选择的日期范围
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        
        // 验证日期范围
        if startDate > endDate {
            activityIndicator.stopAnimating()
            exportButton.isEnabled = true
            showAlert(title: "错误", message: "开始日期不能晚于结束日期")
            return
        }
        
        healthManager.exportWorkoutsToCSV(startDate: startDate, endDate: endDate) { [weak self] csvString, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.exportButton.isEnabled = true
                
                if let error = error {
                    self?.statusLabel.text = "导出失败: \(error.localizedDescription)"
                    self?.showAlert(title: "导出失败", message: error.localizedDescription)
                    return
                }
                
                guard let csvString = csvString else {
                    self?.statusLabel.text = "没有找到健身记录"
                    self?.showAlert(title: "提示", message: "没有找到可导出的健身记录")
                    return
                }
                
                // 保存CSV文件
                let fileName = "workout_export_\(Date().timeIntervalSince1970).csv"
                if let fileURL = self?.healthManager.saveCSVToFile(csvString, fileName: fileName) {
                    self?.statusLabel.text = "导出成功！文件已保存"
                    self?.shareCSVFile(fileURL: fileURL)
                } else {
                    self?.statusLabel.text = "保存文件失败"
                    self?.showAlert(title: "错误", message: "保存CSV文件失败")
                }
            }
        }
    }
    
    private func shareCSVFile(fileURL: URL) {
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        
        // 为iPad设置popover位置
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.exportButton
            popoverController.sourceRect = self.exportButton.bounds
        }
        
        present(activityViewController, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}