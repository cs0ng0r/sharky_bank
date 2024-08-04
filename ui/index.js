document.addEventListener("DOMContentLoaded", function () {
  const bankContainer = document.getElementById("bank");
  const balanceDisplay = document.getElementById("balance-display");
  const depositButton = document.getElementById("deposit-button");
  const withdrawButton = document.getElementById("withdraw-button");
  const closeButton = document.getElementById("close-button");
  const depositAmountInput = document.getElementById("deposit-amount");
  const withdrawAmountInput = document.getElementById("withdraw-amount");

  // Clear input values on opening

  window.addEventListener("message", function (event) {
    if (event.data.type === "openBank") {
      bankContainer.style.display = "block";
      setTimeout(() => {
        bankContainer.classList.add("show");
        depositAmountInput.value = "";
        withdrawAmountInput.value = "";
      }, 10);

      updateBalance(event.data.balance);
    } else if (event.data.type === "closeBank") {
      bankContainer.classList.remove("show");
      setTimeout(() => {
        bankContainer.style.display = "none";
      }, 300);
    }
  });

  function updateBalance(balance) {
    balanceDisplay.textContent = `$${balance.toFixed(2)}`;
    balanceDisplay.classList.add("balance-change");
    setTimeout(() => {
      balanceDisplay.classList.remove("balance-change");
    }, 500);
  }

  function handleFetchResponse(response) {
    return response.text().then((text) => {
      if (!text) {
        throw new Error("Invalid JSON response: Response text is empty.");
      }

      try {
        const jsonResponse = JSON.parse(text);
        if (typeof jsonResponse !== "object" || jsonResponse === null) {
          throw new Error("Invalid JSON response: Invalid JSON structure.");
        }
        return jsonResponse;
      } catch (error) {
        throw new Error("Invalid JSON response");
      }
    });
  }

  closeButton.addEventListener("click", function () {
    fetch(`https://${GetParentResourceName()}/closeBank`, {
      method: "POST",
    }).catch((error) => {
      console.error("Error:", error);
    });
  });

  depositButton.addEventListener("click", function () {
    const amount = parseFloat(document.getElementById("deposit-amount").value);
    if (amount && !isNaN(amount) && amount > 0) {
      fetch(`https://${GetParentResourceName()}/deposit`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify({ amount: amount }),
      })
        .then((response) => {
          return handleFetchResponse(response);
        })
        .then((data) => {
          if (data.success) {
            updateBalance(data.newBalance);
          } else {
            alert(data.message);
          }
        })
        .catch((error) => {
          console.error("Error:", error);
        });
    } else {
      alert("Please enter a valid amount to deposit.");
    }
  });

  withdrawButton.addEventListener("click", function () {
    const amount = parseFloat(document.getElementById("withdraw-amount").value);
    if (amount && !isNaN(amount) && amount > 0) {
      fetch(`https://${GetParentResourceName()}/withdraw`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify({ amount: amount }),
      })
        .then((response) => {
          return handleFetchResponse(response);
        })
        .then((data) => {
          if (data.success) {
            updateBalance(data.newBalance);
          } else {
            alert(data.message);
          }
        })
        .catch((error) => {
          console.error("Error:", error);
        });
    } else {
      alert("Please enter a valid amount to withdraw.");
    }
  });

  window.addEventListener("keyup", (e) => {
    if (e.key === "Escape") {
      fetch(`https://${GetParentResourceName()}/closeBank`, {
        method: "POST",
      });
    }
  });
});
