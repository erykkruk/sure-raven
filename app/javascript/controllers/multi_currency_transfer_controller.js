import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fromAccount",
    "toAccount",
    "sameCurrency",
    "sameCurrencyToggle",
    "currencyInfo",
    "amountFrom",
    "amountTo",
    "amountToContainer",
    "fromCurrencyDisplay",
    "toCurrencyDisplay"
  ]

  static values = {
    accounts: Array
  }

  connect() {
    this.updateCurrencies()
  }

  updateCurrencies() {
    const fromAccountId = this.fromAccountTarget.value
    const toAccountId = this.toAccountTarget.value

    if (!fromAccountId || !toAccountId) {
      this.currencyInfoTarget.classList.add("hidden")
      return
    }

    this.currencyInfoTarget.classList.remove("hidden")

    const fromAccount = this.accountsValue.find(a => String(a.id) === fromAccountId)
    const toAccount = this.accountsValue.find(a => String(a.id) === toAccountId)

    if (!fromAccount || !toAccount) {
      return
    }

    const fromCurrency = fromAccount.currency || "USD"
    const toCurrency = toAccount.currency || "USD"

    // Update currency displays
    this.fromCurrencyDisplayTarget.textContent = fromCurrency
    this.toCurrencyDisplayTarget.textContent = toCurrency

    // Check if currencies are different
    const isDifferentCurrency = fromCurrency !== toCurrency

    if (isDifferentCurrency) {
      // Different currencies - show amount_to field and toggle
      this.sameCurrencyToggleTarget.classList.remove("hidden")
      this.toggleCurrencyMode()
    } else {
      // Same currency - hide multi-currency options
      this.sameCurrencyTarget.checked = true
      this.sameCurrencyToggleTarget.classList.add("hidden")
      this.amountToContainerTarget.classList.add("hidden")
      this.amountToTarget.removeAttribute("required")
    }
  }

  toggleCurrencyMode() {
    const useSameCurrency = this.sameCurrencyTarget.checked

    if (useSameCurrency) {
      // Same currency mode - hide amount_to
      this.amountToContainerTarget.classList.add("hidden")
      this.amountToTarget.removeAttribute("required")
    } else {
      // Multi-currency mode - show amount_to
      this.amountToContainerTarget.classList.remove("hidden")
      this.amountToTarget.setAttribute("required", "required")
    }
  }
}
