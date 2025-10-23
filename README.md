# 🌍 TerraToken Carbon Ledger

A comprehensive blockchain-based carbon credit tracking and offset trading platform. Create, verify, trade, and retire carbon credits through transparent governance and environmental impact management.

## 🌱 Features

- **👥 Multi-User Registration**: Join as Developer, Buyer, Verifier, or Individual with role-based access
- **🏗️ Carbon Project Management**: Create and manage environmental projects with verified methodologies
- **✅ Third-Party Verification**: Independent verification system with fee-based quality assurance
- **💱 Credit Trading Marketplace**: List, buy, and sell carbon credits with automated fee collection
- **🏆 Carbon Offset Retirement**: Permanently retire credits with verifiable certificates
- **📊 Reputation System**: Build trust through active participation and project completion
- **💎 Treasury Management**: Platform fee collection and transparent fund management
- **📈 Impact Analytics**: Track global carbon reduction and offset activities

## 🌿 How It Works

### Platform Participation
1. **💳 User Registration**: Pay 10,000 µSTX registration fee to join with role selection
2. **📍 Location Mapping**: Provide location for regional impact tracking
3. **⭐ Reputation Building**: Start with 100 reputation points
4. **🎯 Role-based Activities**: Engage based on your environmental focus

### Carbon Project Lifecycle
- **🌱 Project Creation**: Developers propose projects with verified methodologies
- **✅ Third-Party Verification**: Pay 50,000 µSTX for independent project verification
- **🏭 Credit Issuance**: Issue verified carbon credits from approved projects
- **💰 Marketplace Trading**: List credits for sale with transparent pricing
- **🔄 Credit Transfer**: Direct peer-to-peer credit transfers
- **🏆 Offset Retirement**: Permanent retirement with certificate generation

### Trading & Impact
- **📈 Market Discovery**: Browse available credits by project and price
- **💱 Automated Trading**: Smart contract-based buying and selling
- **💰 Platform Fees**: 0.05% fee on all transactions (50/1000)
- **🌍 Global Impact**: Track total offsets and environmental benefits

## 🔧 Contract Functions

### User Management

#### `register-user`
Join the TerraToken Carbon Ledger platform.
```clarity
(register-user name user-type location)
```
- **name**: User's name (max 256 chars)
- **user-type**: Role - "Developer", "Buyer", "Verifier", "Individual"
- **location**: Geographic location (max 128 chars)
- **registration-fee**: 10,000 µSTX required
- **initial-reputation**: 100 points

### Carbon Project Operations

#### `register-carbon-project`
Create a new carbon reduction or offset project.
```clarity
(register-carbon-project title description project-type location total-credits methodology)
```
- **title**: Project title (max 256 chars)
- **description**: Detailed project description (max 512 chars)
- **project-type**: Type of carbon project (max 64 chars)
- **location**: Project location (max 128 chars)
- **total-credits**: Maximum credits the project can generate
- **methodology**: Verification methodology used (max 128 chars)

#### `verify-carbon-project`
Verify a carbon project for credit issuance.
```clarity
(verify-carbon-project project-id verification-data)
```
- **project-id**: Project to verify
- **verification-data**: Detailed verification information (max 512 chars)
- **verification-fee**: 50,000 µSTX required
- Updates project status to "verified"

#### `issue-carbon-credits`
Issue verified carbon credits from approved projects.
```clarity
(issue-carbon-credits project-id credits-amount)
```
- **project-id**: Verified project ID
- **credits-amount**: Number of credits to issue
- Only project developers can issue credits
- Credits cannot exceed project total limit

### Trading Marketplace

#### `list-credits-for-sale`
List carbon credits for sale on the marketplace.
```clarity
(list-credits-for-sale project-id credits-amount price-per-credit)
```
- **project-id**: Source project for credits
- **credits-amount**: Number of credits to sell
- **price-per-credit**: Price per credit in µSTX
- Credits are held in escrow until sold or cancelled

#### `buy-carbon-credits`
Purchase carbon credits from marketplace listings.
```clarity
(buy-carbon-credits listing-id)
```
- **listing-id**: Market listing to purchase
- **platform-fee**: 0.05% fee automatically deducted
- Credits transferred immediately to buyer
- Cannot buy your own listings

#### `cancel-credit-listing`
Cancel an active marketplace listing.
```clarity
(cancel-credit-listing listing-id)
```
- Only listing owner can cancel
- Credits returned to seller's balance

### Carbon Offset Management

#### `retire-carbon-credits`
Permanently retire carbon credits as offsets.
```clarity
(retire-carbon-credits project-id credits-amount retirement-reason certificate-hash)
```
- **project-id**: Source project for credits
- **credits-amount**: Number of credits to retire
- **retirement-reason**: Purpose of offset (max 256 chars)
- **certificate-hash**: Unique certificate identifier (max 64 chars)
- Increases user reputation score
- Credits permanently removed from circulation

#### `transfer-credits`
Direct transfer of credits between users.
```clarity
(transfer-credits recipient credits-amount)
```
- **recipient**: Registered user to receive credits
- **credits-amount**: Number of credits to transfer
- Both users must be registered

### Platform Management

#### `deactivate-project`
Deactivate a carbon project (project developer only).
```clarity
(deactivate-project project-id)
```

#### `deactivate-user`
Deactivate a user account (admin only).
```clarity
(deactivate-user user-principal)
```

### Query Functions

#### `get-user`
Retrieve user profile and carbon activity.

#### `get-project`
Get detailed project information and credit status.

#### `get-credit-listing`
View marketplace listing details.

#### `get-retirement-record`
Access carbon offset retirement certificates.

#### `get-platform-stats`
Get comprehensive platform metrics and statistics.

#### `get-user-credits`
Quickly check a user's carbon credit balance.

#### `get-project-credits-available`
Check available credits for a specific project.

## 🛠️ Usage Examples

### Register as Carbon Developer
```bash
clarinet console
(contract-call? .terratoken-carbon-ledger register-user 
  "Green Earth Solutions" 
  "Developer" 
  "Costa Rica")
```

### Create Carbon Project
```bash
(contract-call? .terratoken-carbon-ledger register-carbon-project 
  "Rainforest Conservation Initiative" 
  "Protecting 10,000 hectares of primary rainforest to prevent deforestation" 
  "Forest Conservation" 
  "Amazon Basin, Brazil" 
  u100000 
  "VCS-REDD+ Methodology")
```

### Verify Carbon Project
```bash
(contract-call? .terratoken-carbon-ledger verify-carbon-project 
  u1 
  "Project meets all VCS standards. Baseline established. Monitoring plan approved.")
```

### Issue Carbon Credits
```bash
(contract-call? .terratoken-carbon-ledger issue-carbon-credits 
  u1 
  u5000)
```

### List Credits for Sale
```bash
(contract-call? .terratoken-carbon-ledger list-credits-for-sale 
  u1 
  u1000 
  u50)
```

### Buy Carbon Credits
```bash
(contract-call? .terratoken-carbon-ledger buy-carbon-credits u1)
```

### Retire Credits as Offsets
```bash
(contract-call? .terratoken-carbon-ledger retire-carbon-credits 
  u1 
  u500 
  "Corporate carbon neutrality program - Q4 2024" 
  "CERT-2024-Q4-AMZN-RF001")
```

### Transfer Credits
```bash
(contract-call? .terratoken-carbon-ledger transfer-credits 
  'SP2EXAMPLE...PRINCIPAL 
  u250)
```

### Check Platform Statistics
```bash
(contract-call? .terratoken-carbon-ledger get-platform-stats)
```

## 🔧 Development Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet)
- Node.js (for testing)

### Installation
```bash
git clone <repository>
cd TerraToken-Carbon-Ledger
clarinet check
```

### Testing
```bash
npm install
npm test
```

## 📖 Contract Details

- **Contract Name**: `terratoken-carbon-ledger`
- **Network**: Stacks Blockchain
- **Language**: Clarity
- **Lines of Code**: 379
- **Registration Fee**: 10,000 µSTX
- **Verification Fee**: 50,000 µSTX
- **Platform Fee**: 0.05% (50/1000)
- **Initial Reputation**: 100 points

## 🛡️ Security Features

- ✅ User registration verification for all functions
- ✅ One-time registration per user
- ✅ Project ownership validation
- ✅ Third-party verification system
- ✅ Credit issuance limits (cannot exceed project total)
- ✅ Marketplace escrow system
- ✅ Anti-self-trading protection
- ✅ Credit balance validation
- ✅ Permanent retirement tracking
- ✅ Admin controls for user management

## 💰 Economics & Governance

### Platform Revenue Sources
1. **Registration Fees**: 10,000 µSTX per new user
2. **Verification Fees**: 50,000 µSTX per project verification
3. **Trading Fees**: 0.05% on all credit transactions
4. **Platform Growth**: Expanding user base and project portfolio

### Carbon Credit Economics
- **Project-Based Credits**: Each credit tied to a specific environmental project
- **Verification Required**: All projects must be verified before credit issuance
- **Market-Driven Pricing**: Users set credit prices based on project quality and demand
- **Permanent Retirement**: Offset credits permanently removed from circulation

### Reputation System
- **Base Score**: 100 points for new users
- **Retirement Bonus**: Points for carbon offset retirement (credits/10)
- **Activity Tracking**: Participation in project development and trading
- **Trust Building**: Higher reputation indicates more reliable users

## 🌍 Environmental Impact Use Cases

### Carbon Project Types
- **🌳 Reforestation**: Tree planting and forest restoration projects
- **🌾 Regenerative Agriculture**: Soil carbon sequestration farming practices
- **⚡ Renewable Energy**: Solar, wind, and clean energy installations
- **🏭 Industrial Efficiency**: Manufacturing process improvements
- **🚗 Transportation**: Electric vehicle and clean transit projects
- **🏠 Building Efficiency**: Energy-efficient construction and retrofits

### User Categories
- **🏗️ Project Developers**: Environmental project creators and managers
- **🏢 Corporate Buyers**: Companies purchasing offsets for carbon neutrality
- **✅ Independent Verifiers**: Third-party project verification specialists
- **👥 Individuals**: Personal carbon footprint offset purchasers

### Market Applications
- **🎯 Corporate ESG**: Environmental, Social, Governance compliance
- **🏛️ Regulatory Compliance**: Meeting government carbon reduction mandates
- **🌱 Voluntary Offsets**: Individual and corporate climate action
- **📊 Impact Investment**: Funding environmental projects for returns

## 📊 Platform Analytics

Track key environmental impact metrics:
- Total registered users by role and geographic distribution
- Active carbon projects by type and verification status
- Carbon credits issued, traded, and retired over time
- Marketplace trading volume and price trends
- User reputation scores and participation levels
- Environmental impact calculations and CO2 reductions
- Platform revenue and fee collection analytics

## 🌟 Impact & Outcomes

### Environmental Benefits
- **Carbon Reduction**: Direct measurement of CO2 removed or avoided
- **Project Funding**: Capital flow to verified environmental projects
- **Transparency**: Blockchain-verified environmental claims
- **Global Scale**: Connect projects and buyers worldwide

### Economic Benefits
- **Market Efficiency**: Transparent, liquid carbon credit marketplace
- **Project Viability**: Funding mechanism for environmental initiatives
- **Cost Discovery**: Market-driven pricing for carbon offsets
- **Reduced Friction**: Automated trading and settlement

### Social Impact
- **Community Projects**: Local environmental improvement initiatives
- **Education**: Increased awareness of carbon footprint and offsets
- **Accessibility**: Democratized access to carbon offset markets
- **Trust**: Verifiable environmental impact claims

## 🚀 Future Enhancements

- **🌐 Multi-Chain Support**: Expand to other blockchain networks
- **📱 Mobile Application**: Smartphone interface for credit management
- **🛰️ Satellite Verification**: Automated project monitoring via satellite data
- **🤖 AI Impact Modeling**: Machine learning for project impact prediction
- **🔗 Corporate Integration**: Enterprise API for automated offset purchasing
- **🌍 Global Standards**: Integration with international carbon credit standards
- **💡 Smart Contracts**: Automated credit retirement based on corporate emissions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `clarinet check`
5. Submit a pull request

## 📄 License

This project is open source. See LICENSE file for details.

## 🆘 Support

For questions or technical assistance:
- Create an issue on GitHub
- Join our climate action community
- Contact platform administrators
- Environmental impact verification support

---

*Combating climate change through transparent carbon markets* 🌍🌱
