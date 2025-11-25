# Changelog

All notable changes to this project will be documented in this file.

## [0.6.8] - 2024-11-25

### Fixed
- Added `converted_balance` method to Account model to fix production error
- Currency conversion now works properly in all views
- Multi-currency accounts display correctly with proper exchange rates

## [0.6.7] - 2024-11-25

### Added
- USD triangulation for currency conversion when direct exchange rates are unavailable
- Support for cryptocurrency to fiat currency conversion via triangulation (e.g., ETH→PLN via ETH→USD→PLN)

### Fixed
- Currency summing in balance sheets now correctly converts all currencies
- Yahoo Finance provider now properly wraps responses in Provider::Response format
- ExchangeRate.find_or_fetch_rate now correctly returns ExchangeRate objects
- Multi-currency portfolio totals calculation fixed for accounts with different currencies

### Technical Details
- Implemented triangulation in `Provider::YahooFinance` for missing currency pairs
- Updated `BalanceSheet::AccountTotals` to use ExchangeRate.find_or_fetch_rate with triangulation
- Fixed `Accountable#balance_money` to properly convert currencies using the exchange rate system
- Corrected return value handling in `ExchangeRate::Provided#find_or_fetch_rate`

## [0.6.6] - 2024-11-25

### Added
- Ethereum (ETH) cryptocurrency support
- Initial Docker release workflow documentation

## Previous Versions
- See GitHub releases for earlier version history