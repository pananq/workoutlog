import UIKit
import WebKit
import HealthKit

class HeatmapViewController: UIViewController {
    
    private let healthManager = HealthManager()
    private var webView: WKWebView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var isLandscape = false
    private var currentHeatmapData: [String: [String: Int]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generateAndDisplayHeatmap()
        
        // 监听设备方向变化
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.isLandscape = UIDevice.current.orientation.isLandscape
        }) { _ in
            // 方向变化完成后重新加载热力图
            if let heatmapData = self.getCurrentHeatmapData() {
                self.displayHeatmapHTML(heatmapData: heatmapData)
            }
        }
    }
    
    @objc private func orientationChanged() {
        isLandscape = UIDevice.current.orientation.isLandscape
        if let heatmapData = getCurrentHeatmapData() {
            displayHeatmapHTML(heatmapData: heatmapData)
        }
    }
    
    private func getCurrentHeatmapData() -> [String: [String: Int]]? {
        return currentHeatmapData
    }
    
    private func setupUI() {
        title = "健身热力图"
        view.backgroundColor = .systemBackground
        
        // 初始方向判断
        isLandscape = UIDevice.current.orientation.isLandscape
        
        // 配置WKWebView
        let webConfiguration = WKWebViewConfiguration()
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
    }
    
    private func generateAndDisplayHeatmap() {
        healthManager.generateHeatmapData { [weak self] heatmapData, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let error = error {
                    self?.showAlert(title: "错误", message: "获取数据失败: \(error.localizedDescription)")
                    return
                }
                
                guard let heatmapData = heatmapData, !heatmapData.isEmpty else {
                    self?.showAlert(title: "提示", message: "没有找到健身记录数据")
                    return
                }
                
                // 存储热力图数据
                self?.currentHeatmapData = heatmapData
                self?.displayHeatmapHTML(heatmapData: heatmapData)
            }
        }
    }
    
    private func displayHeatmapHTML(heatmapData: [String: [String: Int]]) {
        let legend = healthManager.getHeatmapLegend()
        
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    margin: 20px;
                    background-color: #f5f5f5;
                }
                .year-container {
                    background: white;
                    border-radius: 10px;
                    padding: 20px;
                    margin-bottom: 20px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    display: inline-block;
                    width: fit-content;
                }
                .year-title {
                    font-size: 18px;
                    font-weight: bold;
                    margin-bottom: 15px;
                    color: #333;
                    text-align: center;
                }
                .month-container {
                    margin-bottom: 10px;
                    display: flex;
                    align-items: center;
                    min-height: 14px;
                }
                .week-container {
                    margin-bottom: 10px;
                    display: flex;
                    align-items: center;
                    min-height: 14px;
                }
                .month-heatmap {
                    display: grid;
                    gap: 2px;
                }
                .week-heatmap {
                    display: grid;
                    grid-template-rows: repeat(7, 14px);
                    grid-auto-flow: column;
                    gap: 2px;
                }
                .week-column {
                    display: contents;
                }
                .day-cell {
                    width: 14px;
                    height: 14px;
                    border-radius: 2px;
                    background-color: #ebedf0;
                }
                .day-cell.level-1 { background-color: #4e79a7; }
                .day-cell.level-2 { background-color: #edc949; }
                .day-cell.level-3 { background-color: #e15759; }
                .day-cell.level-4 { background-color: #76b7b2; }
                .day-cell.level-5 { background-color: #f28e2c; }
                .legend {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 12px;
                    color: #666;
                    margin-top: 10px;
                    gap: 10px;
                }
                .legend-item {
                    display: flex;
                    align-items: center;
                    margin-right: 15px;
                }
                .legend-item .day-cell {
                    margin-right: 8px;
                }
                .stats {
                    font-size: 14px;
                    color: #666;
                    margin-top: 5px;
                }
            </style>
        </head>
        <body>
            <h1>健身记录热力图</h1>
            \(generateHeatmapHTML(heatmapData: heatmapData, legend: legend))
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    private func generateHeatmapHTML(heatmapData: [String: [String: Int]], legend: [String]) -> String {
        var html = ""
        
        // 按年份降序排列
        let sortedYears = heatmapData.keys.sorted { Int($0)! > Int($1)! }
        
        for year in sortedYears {
            guard let yearData = heatmapData[year] else { continue }
            
            let recordedDays = yearData.count
            let totalDays = isLeapYear(Int(year)!) ? 366 : 365
            let percentage = Double(recordedDays) / Double(totalDays) * 100
            
            // 统计每种类型的健身数量
            var workoutCounts: [Int: Int] = [:]
            for (_, value) in yearData {
                workoutCounts[value, default: 0] += 1
            }
            
            html += """
            <div class="year-container">
                <div class="year-title">\(year)年健身记录 (\(recordedDays)/\(totalDays)天, \(String(format: "%.1f", percentage))%)</div>
                \(isLandscape ? generateYearHeatmapByWeek(yearData: yearData, year: Int(year)!) : generateYearHeatmapByMonth(yearData: yearData, year: Int(year)!))
                <div class="legend">
                    \(generateLegendHTML(legend: legend, workoutCounts: workoutCounts))
                </div>
            </div>
            """
        }
        
        return html
    }
    
    private func generateYearHeatmapByMonth(yearData: [String: Int], year: Int) -> String {
        var html = ""
        let calendar = Calendar.current
        
        // 为每个月份生成热力图
        for month in 1...12 {
            let daysInMonth = getDaysInMonth(year: year, month: month)
            
            var monthHTML = ""
            
            // 生成该月份的所有天数单元格
            for day in 1...daysInMonth {
                let dateComponents = DateComponents(year: year, month: month, day: day)
                if let date = calendar.date(from: dateComponents) {
                    let timestamp = "\(Int(date.timeIntervalSince1970))"
                    let level = yearData[timestamp] ?? 0
                    monthHTML += "<div class='day-cell level-\(level)'></div>"
                }
            }
            
            html += """
            <div class="month-container">
                <div class="month-heatmap" style="grid-template-columns: repeat(\(daysInMonth), 14px);">\(monthHTML)</div>
            </div>
            """
        }
        
        return html
    }
    
    private func generateYearHeatmapByWeek(yearData: [String: Int], year: Int) -> String {
        var weekHTML = ""
        let calendar = Calendar.current
        
        // 获取一年的第一天
        let firstDayOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        
        // 获取第一天的星期几（1=周日，2=周一，...，7=周六）
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfYear)
        
        // 计算第一周需要多少个空白单元格
        // 我们需要从周一开始排列，所以需要计算第一天之前需要多少个空白单元格
        // 星期映射：周日=1，周一=2，周二=3，周三=4，周四=5，周五=6，周六=7
        // 空白单元格数量 = (firstDayWeekday + 5) % 7
        // 这个公式确保：周一=0空白，周二=1空白，周三=2空白，...，周日=6空白
        let blankCellsAtStart = (firstDayWeekday + 5) % 7
        
        // 生成一年的所有周
        var currentDate = firstDayOfYear
        var weekCells: [String] = []
        
        // 添加年初的空白单元格
        for _ in 0..<blankCellsAtStart {
            weekCells.append("<div class='day-cell'></div>")
        }
        
        // 生成一年的所有日期单元格
        let lastDayOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        
        while currentDate <= lastDayOfYear {
            let timestamp = "\(Int(currentDate.timeIntervalSince1970))"
            let level = yearData[timestamp] ?? 0
            weekCells.append("<div class='day-cell level-\(level)'></div>")
            
            // 移动到下一天
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDay
            } else {
                break
            }
        }
        
        // 按列排列：每列7个单元格，对应一周
        var columnHTML = ""
        let totalCells = weekCells.count
        let totalWeeks = (totalCells + 6) / 7 // 向上取整
        
        // 按列生成HTML：第一列是第一周，第二列是第二周...
        for week in 0..<totalWeeks {
            var columnCells = ""
            for day in 0..<7 {
                let index = week * 7 + day
                if index < totalCells {
                    columnCells += weekCells[index]
                } else {
                    // 年末的空白单元格
                    columnCells += "<div class='day-cell'></div>"
                }
            }
            columnHTML += "<div class='week-column'>\(columnCells)</div>"
        }
        
        return """
        <div class="week-container">
            <div class="week-heatmap">\(columnHTML)</div>
        </div>
        """
    }
    
    private func getDaysInMonth(year: Int, month: Int) -> Int {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month)
        if let date = calendar.date(from: dateComponents),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31 // 默认值
    }
    
    private func generateLegendHTML(legend: [String], workoutCounts: [Int: Int]) -> String {
        var html = ""
        for (index, item) in legend.enumerated() {
            let level = index + 1
            let count = workoutCounts[level] ?? 0
            html += """
            <div class="legend-item">
                <div class="day-cell level-\(level)"></div>
                <span>\(item) (\(count))</span>
            </div>
            """
        }
        return html
    }
    
    private func isLeapYear(_ year: Int) -> Bool {
        return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HeatmapViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 页面加载完成
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showAlert(title: "错误", message: "加载热力图失败: \(error.localizedDescription)")
    }
}