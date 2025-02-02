<aside class="sidebar">
    <div class="sidebar-header">
        <img src="<?= asset('img/logo.png') ?>" alt="Logo" class="logo">
        <h1><?= APP_NAME ?></h1>
    </div>

    <nav class="sidebar-nav">
        <ul>
            <li class="<?= $_SERVER['REQUEST_URI'] === '/dashboard' ? 'active' : '' ?>">
                <a href="/dashboard">
                    <i class="fas fa-tachometer-alt"></i>
                    <span>Dashboard</span>
                </a>
            </li>
            <li class="<?= strpos($_SERVER['REQUEST_URI'], '/system') === 0 ? 'active' : '' ?>">
                <a href="/system">
                    <i class="fas fa-server"></i>
                    <span>System</span>
                </a>
            </li>
            <li class="<?= strpos($_SERVER['REQUEST_URI'], '/services') === 0 ? 'active' : '' ?>">
                <a href="/services">
                    <i class="fas fa-cogs"></i>
                    <span>Services</span>
                </a>
            </li>
            <li class="<?= strpos($_SERVER['REQUEST_URI'], '/files') === 0 ? 'active' : '' ?>">
                <a href="/files">
                    <i class="fas fa-folder"></i>
                    <span>File Manager</span>
                </a>
            </li>
            <li class="<?= strpos($_SERVER['REQUEST_URI'], '/database') === 0 ? 'active' : '' ?>">
                <a href="/database">
                    <i class="fas fa-database"></i>
                    <span>Database</span>
                </a>
            </li>
            <li class="<?= strpos($_SERVER['REQUEST_URI'], '/security') === 0 ? 'active' : '' ?>">
                <a href="/security">
                    <i class="fas fa-shield-alt"></i>
                    <span>Security</span>
                </a>
            </li>
        </ul>
    </nav>
</aside>
