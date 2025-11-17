let currentLocationId = null;
let currentStorage = null;
let storageTiers = {};
let placementCoords = null;
let placementHeading = null;

// NUI Message Handler
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === 'openStorageMenu') {
        currentLocationId = data.locationId;
        currentStorage = data.storage;
        storageTiers = data.tiers;
        
        if (currentStorage) {
            // Player owns storage
            showStorageAccess();
        } else {
            // No storage owned
            showPurchaseView();
        }
        
        document.getElementById('storage-menu').classList.remove('hidden');
    } else if (data.action === 'openPlacementMenu') {
        placementCoords = data.coords;
        placementHeading = data.heading;
        
        document.getElementById('coord-x').textContent = data.coords.x.toFixed(2);
        document.getElementById('coord-y').textContent = data.coords.y.toFixed(2);
        document.getElementById('coord-z').textContent = data.coords.z.toFixed(2);
        
        document.getElementById('placement-menu').classList.remove('hidden');
    }
});

// Show purchase view
function showPurchaseView() {
    document.getElementById('no-storage-view').classList.remove('hidden');
    document.getElementById('access-tab').classList.add('hidden');
    document.getElementById('upgrade-tab').classList.add('hidden');
    document.getElementById('password-tab').classList.add('hidden');
    
    // Hide nav items for purchase
    document.querySelectorAll('.nav-item').forEach(item => {
        item.style.display = 'none';
    });
    
    const tier1 = storageTiers[1];
    document.getElementById('purchase-slots').textContent = tier1.slots + ' Slots';
    document.getElementById('purchase-weight').textContent = (tier1.weight / 1000) + 'kg Capacity';
    document.getElementById('purchase-price').textContent = '$' + formatNumber(tier1.price);
}

// Show storage access
function showStorageAccess() {
    document.getElementById('no-storage-view').classList.add('hidden');
    
    // Show nav items
    document.querySelectorAll('.nav-item').forEach(item => {
        item.style.display = 'flex';
    });
    
    switchTab('access');
    updateStorageInfo();
}

// Switch tabs
function switchTab(tab) {
    document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
    event.target.closest('.nav-item').classList.add('active');
    
    document.getElementById('access-tab').classList.add('hidden');
    document.getElementById('upgrade-tab').classList.add('hidden');
    document.getElementById('password-tab').classList.add('hidden');
    
    if (tab === 'access') {
        document.getElementById('access-tab').classList.remove('hidden');
        updateStorageInfo();
    } else if (tab === 'upgrade') {
        document.getElementById('upgrade-tab').classList.remove('hidden');
        loadUpgradeOptions();
    } else if (tab === 'password') {
        document.getElementById('password-tab').classList.remove('hidden');
    }
}

// Update storage info
function updateStorageInfo() {
    if (!currentStorage) return;
    
    const tier = storageTiers[currentStorage.tier];
    
    document.getElementById('current-tier-badge').textContent = tier.name;
    document.getElementById('storage-slots').textContent = tier.slots + ' Slots';
    document.getElementById('storage-weight').textContent = (tier.weight / 1000) + 'kg';
    document.getElementById('storage-tier-text').textContent = currentStorage.tier + '/' + Object.keys(storageTiers).length;
}

// Load upgrade options
function loadUpgradeOptions() {
    const container = document.getElementById('upgrade-options');
    container.innerHTML = '';
    
    Object.keys(storageTiers).forEach(tierNum => {
        const tier = storageTiers[tierNum];
        const isCurrent = currentStorage.tier == tierNum;
        const isLocked = currentStorage.tier < tierNum - 1;
        const canUpgrade = currentStorage.tier == tierNum - 1;
        
        const card = document.createElement('div');
        card.className = 'upgrade-card';
        if (isCurrent) card.classList.add('current');
        if (isLocked) card.classList.add('locked');
        
        let statusHTML = '';
        if (isCurrent) {
            statusHTML = '<span class="upgrade-status status-current">Current</span>';
        } else if (isLocked) {
            statusHTML = '<span class="upgrade-status status-locked">Locked</span>';
        }
        
        card.innerHTML = `
            <div class="upgrade-header">
                <div class="upgrade-tier">Tier ${tierNum}</div>
                ${statusHTML}
            </div>
            <h4 style="font-size: 18px; font-weight: 700; color: #fff; margin-bottom: 8px;">${tier.name}</h4>
            <p>${tier.description}</p>
            <div class="upgrade-stats">
                <div class="stat">
                    <i class="fas fa-box"></i>
                    <span>${tier.slots} Slots</span>
                </div>
                <div class="stat">
                    <i class="fas fa-weight-hanging"></i>
                    <span>${tier.weight / 1000}kg</span>
                </div>
            </div>
            ${!isCurrent ? `
                <div class="upgrade-price">
                    <span>${tierNum == 1 ? 'Purchase Price' : 'Upgrade Cost'}</span>
                    <strong>$${formatNumber(tier.price)}</strong>
                </div>
            ` : ''}
            ${canUpgrade ? `
                <button class="btn btn-success btn-lg" onclick="upgradeStorage()">
                    <i class="fas fa-arrow-up"></i> Upgrade Now
                </button>
            ` : ''}
        `;
        
        container.appendChild(card);
    });
}

// Purchase storage
function purchaseStorage() {
    const password = document.getElementById('purchase-password').value;
    
    if (!password || password.length < 4) {
        showNotification('Password must be at least 4 characters', 'error');
        return;
    }
    
    if (password.length > 12) {
        showNotification('Password must be 12 characters or less', 'error');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/purchaseStorage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            locationId: currentLocationId,
            password: password
        })
    });
}

// Upgrade storage
function upgradeStorage() {
    fetch(`https://${GetParentResourceName()}/upgradeStorage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            storageId: currentStorage.id
        })
    });
}

// Access storage
function accessStorage() {
    const password = document.getElementById('access-password').value;
    
    if (!password) {
        showNotification('Please enter your password', 'error');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/accessStorage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            storageId: currentStorage.id,
            password: password
        })
    });
}

// Change password
function changePassword() {
    const newPassword = document.getElementById('new-password').value;
    const confirmPassword = document.getElementById('confirm-password').value;
    
    if (!newPassword || newPassword.length < 4) {
        showNotification('Password must be at least 4 characters', 'error');
        return;
    }
    
    if (newPassword.length > 12) {
        showNotification('Password must be 12 characters or less', 'error');
        return;
    }
    
    if (newPassword !== confirmPassword) {
        showNotification('Passwords do not match', 'error');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/changePassword`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            storageId: currentStorage.id,
            newPassword: newPassword
        })
    });
    
    document.getElementById('new-password').value = '';
    document.getElementById('confirm-password').value = '';
}

// Close menu
function closeMenu() {
    document.getElementById('storage-menu').classList.add('hidden');
    currentLocationId = null;
    currentStorage = null;
    
    // Reset fields
    document.getElementById('purchase-password').value = '';
    document.getElementById('access-password').value = '';
    
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

// Placement menu
function confirmPlacement() {
    const label = document.getElementById('location-label').value;
    const blip = document.getElementById('location-blip').checked;
    
    if (!label || label.trim() === '') {
        showNotification('Please enter a location label', 'error');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/createLocation`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            coords: placementCoords,
            heading: placementHeading,
            label: label,
            blip: blip
        })
    });
    
    closePlacementMenu();
}

function closePlacementMenu() {
    document.getElementById('placement-menu').classList.add('hidden');
    document.getElementById('location-label').value = '';
    
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

// Utilities
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function showNotification(message, type) {
    // This would integrate with your notification system
    console.log(`[${type}] ${message}`);
}

function GetParentResourceName() {
    if (window.location.href.includes('://nui_')) {
        return window.location.href.split('://nui_')[1].split('/')[0];
    }
    return 'quanxk5_storage';
}

// ESC key handler
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        if (!document.getElementById('storage-menu').classList.contains('hidden')) {
            closeMenu();
        }
        if (!document.getElementById('placement-menu').classList.contains('hidden')) {
            closePlacementMenu();
        }
    }
});

console.log('[QuanXk5 Storage] UI loaded successfully');
