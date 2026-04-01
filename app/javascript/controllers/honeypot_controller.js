import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="honeypot"
export default class extends Controller {
  static targets = ["field"]

  connect() {
    // We can clear any pre-filled value if needed, but usually bots fill it.
    this.fieldTarget.value = ""
  }

  // Intercept the form submission if needed, 
  // but we'll primarily rely on the server-side check.
  // This client-side check is a secondary defense.
  submit(event) {
    if (this.fieldTarget.value.length > 0) {
      console.warn("Spam detected via honeypot.")
      event.preventDefault() // Block submission
      alert("스팸이 감지되었습니다.")
    }
  }
}
