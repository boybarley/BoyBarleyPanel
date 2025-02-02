<?php $title = 'Dashboard'; ?>

<div class="dashboard-grid">
    <!-- System Overview -->
    <div class="card">
        <div class="card-header">
            <h2>System Overview</h2>
        </div>
        <div class="card-body">
            <div class="stats-grid">
                <div class="stat-item">
                    <i class="fas fa-microchip"></i>
                    <div class="stat-info">
                        <h3>CPU Load</h3>
                        <p><?= number_format($systemInfo['cpu'][0], 2) ?></p>
                    </div>
                </div>
                <div class="stat-item">
                    <i class="fas fa-memory"></i>
                    <div class="stat-info">
                        <h3>Memory Usage</h3>
                        <p><?= formatBytes($systemInfo['memory']['used']) ?> / <?= formatBytes($systemInfo['memory']['total']) ?></p>
                    </div>
                </div>
                <div class="stat-item">
                    <i class="fas fa-hdd"></i>
                    <div class="stat-info">
                        <h3>Disk Space</h3>
                        <p><?= formatBytes($systemInfo['disk']) ?> free</p>
                    </div>
                </div>
                <div class="stat-item">
                    <i class="fas fa-clock"></i>
                    <div class="stat-info">
                        <h3>Uptime</h3>
                        <p><?= $systemInfo['uptime'] ?></p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="card">
        <div class="card-header">
            <h2>Quick Actions</h2>
        </div>
        <div class="card-body">
            <div class="quick-actions">
                <button class="action-btn" data-action="restart-nginx">
                    <i class="fas fa-sync"></i>
                    Restart Nginx
                </button>
                <button class="action-btn" data-action="restart-php">
                    <i class="fas fa-sync"></i>
                    Restart PHP
                </button>
                <button class="action-btn" data-action="restart-mysql">
                    <i class="fas fa-sync"></i>
                    Restart MySQL
                </button>
                <button class="action-btn" data-action="backup">
                    <i class="fas fa-download"></i>
                    Backup System
                </button>
            </div>
        </div>
    </div>

    <!-- Recent Activities -->
    <div class="card">
        <div class="card-header">
            <h2>Recent Activities</h2>
        </div>
        <div class="card-body">
            <div class="activity-list">
                <?php foreach ($recentActivities ?? [] as $activity): ?>
                    <div class="activity-item">
                        <i class="<?= $activity['icon'] ?>"></i>
                        <div class="activity-info">
                            <p><?= $activity['description'] ?></p>
                            <small><?= $activity['time'] ?></small>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>
    </div>
</div>
