import Foundation
import HealthKit

class HealthManager {
    
    private let healthStore = HKHealthStore()
    
    // 获取健身记录（支持时间范围筛选）
    func fetchWorkouts(startDate: Date? = nil, endDate: Date? = nil, completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        var predicates: [NSPredicate] = []
        
        // 添加持续时间大于0的谓词
        predicates.append(HKQuery.predicateForWorkouts(with: .greaterThan, duration: 0))
        
        // 添加时间范围谓词
        if let startDate = startDate, let endDate = endDate {
            let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            predicates.append(datePredicate)
        }
        
        // 组合所有谓词
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: HKWorkoutType.workoutType(),
            predicate: compoundPredicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                completion(nil, error)
                return
            }
            completion(workouts, nil)
        }
        
        healthStore.execute(query)
    }
    
    // 获取特定健身类型的统计数据
    func fetchStatistics(for workout: HKWorkout, quantityType: HKQuantityType, completion: @escaping (HKStatistics?, Error?) -> Void) {
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, statistics, error in
            completion(statistics, error)
        }
        
        healthStore.execute(query)
    }
    
    // 导出健身数据为CSV（支持时间范围）
    func exportWorkoutsToCSV(startDate: Date? = nil, endDate: Date? = nil, completion: @escaping (String?, Error?) -> Void) {
        fetchWorkouts(startDate: startDate, endDate: endDate) { workouts, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let workouts = workouts, !workouts.isEmpty else {
                completion(nil, NSError(domain: "HealthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "没有找到健身记录"]))
                return
            }
            
            // CSV头部
            var csvString = "开始时间,结束时间,持续时间(分钟),健身类型,卡路里(千卡),距离(米),平均心率\n"
            
            let group = DispatchGroup()
            var csvLines: [String] = []
            
            for workout in workouts {
                group.enter()
                
                var lineComponents: [String] = []
                
                // 基本信息
                let startDate = workout.startDate
                let endDate = workout.endDate
                let duration = workout.duration / 60 // 转换为分钟
                let workoutType = self.workoutTypeString(workout.workoutActivityType)
                
                lineComponents.append(self.formatDate(startDate))
                lineComponents.append(self.formatDate(endDate))
                lineComponents.append(String(format: "%.1f", duration))
                lineComponents.append(workoutType)
                
                // 获取卡路里数据
                if let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                    self.fetchStatistics(for: workout, quantityType: energyType) { statistics, _ in
                        if let statistics = statistics, let sum = statistics.sumQuantity() {
                            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                            lineComponents.append(String(format: "%.0f", calories))
                        } else {
                            lineComponents.append("0")
                        }
                        
                        // 获取距离数据
                        if let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
                            self.fetchStatistics(for: workout, quantityType: distanceType) { statistics, _ in
                                if let statistics = statistics, let sum = statistics.sumQuantity() {
                                    let distance = sum.doubleValue(for: HKUnit.meter())
                                    lineComponents.append(String(format: "%.0f", distance))
                                } else {
                                    lineComponents.append("0")
                                }
                                
                                // 获取心率数据（这里简化处理）
                                lineComponents.append("0") // 平均心率占位
                                
                                // 完成这一行的数据收集
                                csvLines.append(lineComponents.joined(separator: ","))
                                group.leave()
                            }
                        } else {
                            lineComponents.append("0")
                            lineComponents.append("0")
                            csvLines.append(lineComponents.joined(separator: ","))
                            group.leave()
                        }
                    }
                } else {
                    lineComponents.append("0")
                    lineComponents.append("0")
                    lineComponents.append("0")
                    csvLines.append(lineComponents.joined(separator: ","))
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                // 按时间排序（最新的在前面）
                let sortedLines = csvLines.sorted { line1, line2 in
                    let date1 = line1.split(separator: ",")[0]
                    let date2 = line2.split(separator: ",")[0]
                    return date1 > date2
                }
                
                csvString += sortedLines.joined(separator: "\n")
                completion(csvString, nil)
            }
        }
    }
    
    // 健身类型转换为字符串
    private func workoutTypeString(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .americanFootball: return "americanFootball"
        case .archery: return "archery"
        case .australianFootball: return "australianFootball"
        case .badminton: return "badminton"
        case .baseball: return "baseball"
        case .basketball: return "basketball"
        case .bowling: return "bowling"
        case .boxing: return "boxing"
        case .climbing: return "climbing"
        case .cricket: return "cricket"
        case .crossTraining: return "crossTraining"
        case .curling: return "curling"
        case .cycling: return "cycling"
        case .dance: return "dance"
        case .danceInspiredTraining: return "danceInspiredTraining"
        case .elliptical: return "elliptical"
        case .equestrianSports: return "equestrianSports"
        case .fencing: return "fencing"
        case .fishing: return "fishing"
        case .functionalStrengthTraining: return "functionalStrengthTraining"
        case .golf: return "golf"
        case .gymnastics: return "gymnastics"
        case .handball: return "handball"
        case .hiking: return "hiking"
        case .hockey: return "hockey"
        case .hunting: return "hunting"
        case .lacrosse: return "lacrosse"
        case .martialArts: return "martialArts"
        case .mindAndBody: return "mindAndBody"
        case .mixedMetabolicCardioTraining: return "mixedMetabolicCardioTraining"
        case .paddleSports: return "paddleSports"
        case .play: return "play"
        case .preparationAndRecovery: return "preparationAndRecovery"
        case .racquetball: return "racquetball"
        case .rowing: return "rowing"
        case .rugby: return "rugby"
        case .running: return "running"
        case .sailing: return "sailing"
        case .skatingSports: return "skatingSports"
        case .snowSports: return "snowSports"
        case .soccer: return "soccer"
        case .softball: return "softball"
        case .squash: return "squash"
        case .stairClimbing: return "stairClimbing"
        case .surfingSports: return "surfingSports"
        case .swimming: return "swimming"
        case .tableTennis: return "tableTennis"
        case .tennis: return "tennis"
        case .trackAndField: return "trackAndField"
        case .traditionalStrengthTraining: return "traditionalStrengthTraining"
        case .volleyball: return "volleyball"
        case .walking: return "walking"
        case .waterFitness: return "waterFitness"
        case .waterPolo: return "waterPolo"
        case .waterSports: return "waterSports"
        case .wrestling: return "wrestling"
        case .yoga: return "yoga"
        case .barre: return "barre"
        case .coreTraining: return "coreTraining"
        case .crossCountrySkiing: return "crossCountrySkiing"
        case .downhillSkiing: return "downhillSkiing"
        case .flexibility: return "flexibility"
        case .highIntensityIntervalTraining: return "highIntensityIntervalTraining"
        case .jumpRope: return "jumpRope"
        case .kickboxing: return "kickboxing"
        case .pilates: return "pilates"
        case .snowboarding: return "snowboarding"
        case .stairs: return "stairs"
        case .stepTraining: return "stepTraining"
        case .wheelchairWalkPace: return "wheelchairWalkPace"
        case .wheelchairRunPace: return "wheelchairRunPace"
        case .taiChi: return "taiChi"
        case .mixedCardio: return "mixedCardio"
        case .handCycling: return "handCycling"
        case .discSports: return "discSports"
        case .fitnessGaming: return "fitnessGaming"
        case .cardioDance: return "cardioDance"
        case .socialDance: return "socialDance"
        case .pickleball: return "pickleball"
        case .cooldown: return "cooldown"
        case .swimBikeRun: return "swimBikeRun"
        case .transition: return "transition"
        case .underwaterDiving: return "underwaterDiving"
        default: return "other"
        }
    }
    
    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // 保存CSV到文件
    func saveCSVToFile(_ csvString: String, fileName: String) -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("保存CSV文件失败: \(error)")
            return nil
        }
    }
}