import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fromAccount",
    "toAccount", 
    "sameCurrency",
    "singleAmount",
    "multiAmount",
    "amountFrom",
    "amountFromMulti",
    "amountTo",
    "fromCurrencyDisplay",
    "fromCurrencyMultiDisplay",
    "toCurrencyDisplay",
    "sameCurrencyToggle",
    "currencyInfo"
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
    
    const fromAccount = this.accountsValue.find(a => a.id === fromAccountId)
    const toAccount = this.accountsValue.find(a => a.id === toAccountId)
    
    if (!fromAccount || !toAccount) {
      return
    }
    
    const fromCurrency = fromAccount.currency || "USD"
    const toCurrency = toAccount.currency || "USD"
    
    // Update currency displays
    this.fromCurrencyDisplayTarget.textContent = fromCurrency
    this.fromCurrencyMultiDisplayTarget.textContent = fromCurrency
    this.toCurrencyDisplayTarget.textContent = toCurrency
    
    // Check if currencies match
    const sameCurrency = fromCurrency === toCurrency
    
    if (sameCurrency) {
      // Same currency - hide multi-currency options
      this.sameCurrencyTarget.checked = true
      this.sameCurrencyToggleTarget.classList.add("hidden")
      this.singleAmountTarget.classList.remove("hidden")
      this.multiAmountTarget.classList.add("hidden")
      
      // Set required attributes
      this.amountFromTarget.setAttribute("required", "required")
      this.amountFromMultiTarget.removeAttribute("required")
      this.amountToTarget.removeAttribute("required")
    } else {
      // Different currencies - show multi-currency options
      this.sameCurrencyToggleTarget.classList.remove("hidden")
      this.toggleCurrencyMode()
    }
  }
  
  toggleCurrencyMode() {
    const useSameCurrency = this.sameCurrencyTarget.checked
    
    if (useSameCurrency) {
      // Single amount mode
      this.singleAmountTarget.classList.remove("hidden")
      this.multiAmountTarget.classList.add("hidden")
      
      // Set required attributes
      this.amountFromTarget.setAttribute("required", "required")
      this.amountFromMultiTarget.removeAttribute("required")
      this.amountToTarget.removeAttribute("required")
      
      // Copy value to hidden multi field
      this.amountFromMultiTarget.value = this.amountFromTarget.value
      this.amountToTarget.value = this.amountFromTarget.value
    } else {
      // Multi-amount mode
      this.singleAmountTarget.classList.add("hidden")
      this.multiAmountTarget.classList.remove("hidden")
      
      // Set required attributes
      this.amountFromTarget.removeAttribute("required")
      this.amountFromMultiTarget.setAttribute("required", "required")
      this.amountToTarget.setAttribute("required", "required")
      
      // Copy value from single to multi field if needed
      if (this.amountFromTarget.value && !this.amountFromMultiTarget.value) {
        this.amountFromMultiTarget.value = this.amountFromTarget.value
      }
    }
  }
}