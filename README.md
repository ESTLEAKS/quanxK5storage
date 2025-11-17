# QuanXk5 Storage System 🏪

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-green.svg)
![ESX](https://img.shields.io/badge/ESX-Required-red.svg)

**Made by QuanXk5 Development ❤️**

An advanced storage system for FiveM ESX servers featuring upgradeable storage units, password protection, and admin placement tools.

---

## ✨ Features

- **4-Tier Upgrade System**: Start with basic storage and upgrade to premium
- **Password Protection**: Secure your items with custom passwords
- **Admin Placement**: Authorized admins can place storage locations anywhere
- **Beautiful UI**: Modern, clean interface based on your template
- **QuanNotify Integration**: Seamless notifications
- **Ox Inventory Support**: Full integration with ox_inventory
- **Database Persistence**: All data saved securely

---

## 📋 Requirements

- **ESX Framework** (Latest version)
- **oxmysql** or **mysql-async**
- **ox_inventory**
- **quan_notify** (Your notification system)

---

## 📦 Installation

### 1. Download & Extract
Extract `quanxk5_storage` to your server's `resources` folder.

### 2. Database Setup
Execute the `storage.sql` file in your database:
```sql
-- Run this in your MySQL/MariaDB database
```

### 3. Configure Admin Licenses
Open `config.lua` and add FiveM licenses for admins who can place storage locations:
```lua
Config.AdminLicenses = {
    'license:abc123example', -- Replace with actual licenses
    'license:def456example',
}
```

### 4. Adjust Storage Tiers (Optional)
Customize prices, slots, and weight limits in `config.lua`:
```lua
Config.StorageTiers = {
    [1] = {
        name = 'Basic Storage',
        slots = 25,
        weight = 100000,
        price = 50000, -- Modify prices here
        description = 'Small storage unit'
    },
    -- ... more tiers
}
```

### 5. Add to server.cfg
```cfg
ensure quanxk5_storage
```

### 6. Restart Server
```bash
restart your-server
```

---

## 🎮 Usage

### For Admins

#### Place Storage Locations
Admins with configured licenses can place storage units:
```
/placestorage
```

**Controls:**
- **Left Click**: Place storage location
- **Right Click**: Cancel placement
- **ESC**: Exit placement mode

Once placed, enter:
- Location label (e.g., "Downtown Storage #1")
- Choose if it should appear on map

### For Players

#### Purchase Storage
1. Go to any storage location (marked with blip if enabled)
2. Press **E** to interact
3. Set a secure password (4-12 characters)
4. Purchase for **$50,000** (default Tier 1 price)

#### Access Storage
1. Approach your storage location
2. Press **E** and enter your password
3. Storage inventory opens automatically

#### Upgrade Storage
1. Access your storage menu
2. Click "Upgrade Storage" tab
3. View available tiers and prices:
   - **Tier 1**: $50,000 (25 slots, 100kg)
   - **Tier 2**: $500,000 (50 slots, 200kg)
   - **Tier 3**: $1,500,000 (75 slots, 350kg)
   - **Tier 4**: $3,000,000 (100 slots, 500kg)
4. Click "Upgrade Now" when ready

#### Change Password
1. Open storage menu
2. Go to "Change Password" tab
3. Enter new password (4-12 characters)
4. Confirm password
5. Click "Update Password"

---

## 🔧 Configuration

### Key Config Options

```lua
-- Admin permissions
Config.AdminLicenses = {
    'license:your_license_here'
}

-- Password settings
Config.PasswordMinLength = 4
Config.PasswordMaxLength = 12
Config.PasswordRequired = true

-- Interaction
Config.InteractionDistance = 2.5 -- Distance to interact (meters)
Config.UseTarget = false -- Set true for ox_target/qb-target

-- Blips
Config.Blips = {
    enabled = true,
    sprite = 478,
    color = 5,
    scale = 0.8,
    name = 'Storage Unit'
}

-- Storage tiers (fully customizable)
Config.StorageTiers = {
    [1] = { name = '...', slots = 25, weight = 100000, price = 50000 },
    [2] = { name = '...', slots = 50, weight = 200000, price = 500000 },
    [3] = { name = '...', slots = 75, weight = 350000, price = 1500000 },
    [4] = { name = '...', slots = 100, weight = 500000, price = 3000000 }
}
```

---

## 📊 Database Structure

### `storage_locations`
Stores all placed storage locations.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Unique location ID |
| coords | TEXT | JSON coordinates |
| heading | FLOAT | Player heading |
| label | VARCHAR | Location name |
| blip | TINYINT | Show on map (0/1) |
| created_at | TIMESTAMP | Creation time |

### `player_storages`
Stores player-owned storage units.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Unique storage ID |
| identifier | VARCHAR | Player identifier |
| location_id | INT | Location reference |
| tier | INT | Current tier (1-4) |
| password | VARCHAR | Hashed password |
| purchased_at | TIMESTAMP | Purchase time |
| last_accessed | TIMESTAMP | Last access time |

---

## 🎨 Customization

### UI Colors
Edit `html/style.css` to change colors:
```css
.btn-success {
    background: #10b981; /* Green accent */
}

.sidebar {
    background: #0d0d0d; /* Dark sidebar */
}
```

### Notification Messages
Edit `config.lua` notifications:
```lua
Config.Notifications = {
    purchaseSuccess = {
        title = 'Storage Purchased',
        message = 'You successfully purchased a storage unit for $%s',
        type = 'success',
        duration = 7500
    },
    -- ... more notifications
}
```

---

## 🐛 Troubleshooting

### Storage Won't Open
- Check ox_inventory is running
- Verify database tables exist
- Check player has password set

### Can't Place Locations
- Verify your license is in `Config.AdminLicenses`
- Check console for errors
- Ensure permissions are correct

### Upgrades Not Working
- Check player has sufficient money
- Verify tier configuration
- Check ox_inventory stash registration

### Console Errors
Enable debug mode in `config.lua`:
```lua
Config.Debug = true
```

---

## 📝 Commands

| Command | Permission | Description |
|---------|-----------|-------------|
| `/placestorage` | Admin (Config) | Enter placement mode |

---

## 🔄 Updates & Support

For updates, bug reports, or feature requests:
- **Discord**: QuanXk5 Development
- **GitHub**: [Your Repository]

---

## 📄 License

This resource is created by **QuanXk5 Development**.
- ✅ Free to use on your server
- ✅ Modify for personal use
- ❌ Do not redistribute without permission
- ❌ Do not remove credits

---

## 🙏 Credits

**Made with ❤️ by QuanXk5 Development**

Special thanks to:
- ESX Framework Team
- Overextended (ox_inventory)
- FiveM Community

---

## 🚀 Future Features

- [ ] Multiple storage units per player
- [ ] Storage rental system
- [ ] Shared storage for gangs/jobs
- [ ] Storage logs and history
- [ ] Mobile storage access
- [ ] Storage transfer system

---

**Enjoy the storage system! If you need support, don't hesitate to reach out.** 🎮
