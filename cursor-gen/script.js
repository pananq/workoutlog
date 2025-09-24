function createWorkoutGrid(year) {
    const data = workoutData[year];
    const container = document.getElementById('workoutLog');
    const yearTitle = document.getElementById('yearTitle');
    
    yearTitle.textContent = data.title;
    
    // 创建网格容器
    const grid = document.createElement('div');
    grid.className = 'workout-grid';
    
    // 添加月份标题
    grid.appendChild(document.createElement('div')); // 空白格子
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    months.forEach(month => {
        const monthDiv = document.createElement('div');
        monthDiv.className = 'month-header';
        monthDiv.textContent = month;
        grid.appendChild(monthDiv);
    });
    
    // 添加星期和日期格子
    const days = ['Tue', 'Thu', 'Sat'];
    days.forEach(day => {
        const dayLabel = document.createElement('div');
        dayLabel.className = 'day-label';
        dayLabel.textContent = day;
        grid.appendChild(dayLabel);
        
        // 为每一天创建格子
        for (let month = 0; month < 12; month++) {
            const cell = document.createElement('div');
            cell.className = 'workout-cell empty';
            grid.appendChild(cell);
        }
    });
    
    // 添加图例
    const legend = document.createElement('div');
    legend.className = 'legend';
    data.activities.forEach(activity => {
        const legendItem = document.createElement('div');
        legendItem.className = 'legend-item';
        
        const color = document.createElement('div');
        color.className = `legend-color ${activity.type}`;
        
        const label = document.createElement('span');
        label.textContent = `${activity.type} (${activity.count})`;
        
        legendItem.appendChild(color);
        legendItem.appendChild(label);
        legend.appendChild(legendItem);
    });
    
    container.appendChild(grid);
    container.appendChild(legend);
}

// 页面加载时初始化
document.addEventListener('DOMContentLoaded', () => {
    createWorkoutGrid(2024);
}); 