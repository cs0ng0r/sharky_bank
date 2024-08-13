document.addEventListener("DOMContentLoaded", function () {
  const bankContainer = document.getElementById("bank");
  const balanceDisplay = document.getElementById("balance-display");
  const depositButton = document.getElementById("deposit-button");
  const withdrawButton = document.getElementById("withdraw-button");
  const closeButton = document.getElementById("close-button");
  const amountInput = document.getElementById("amount-input");

  let previousBalance = 0;

  window.addEventListener("message", function (event) {
    if (event.data.type === "openBank") {
      bankContainer.style.display = "block";
      setTimeout(() => {
        bankContainer.classList.add("show");
        amountInput.value = "";
      }, 10);

      updateBalance(event.data.balance);
    } else if (event.data.type === "closeBank") {
      bankContainer.classList.remove("show");
      setTimeout(() => {
        bankContainer.style.display = "none";
      }, 300);
    } else if (event.data.type === "updateBalance") {
      updateBalance(event.data.balance);
    }
  });

  function updateBalance(newBalance) {
    const balance = parseFloat(newBalance);
    balanceDisplay.textContent = `$${balance.toFixed(2)}`;

    if (balance > previousBalance) {
      balanceDisplay.classList.remove("balance-decrease");
      balanceDisplay.classList.add("balance-increase");
    } else if (balance < previousBalance) {
      balanceDisplay.classList.remove("balance-increase");
      balanceDisplay.classList.add("balance-decrease");
    } else {
      balanceDisplay.classList.remove("balance-increase", "balance-decrease");
    }

    previousBalance = balance;

    setTimeout(() => {
      balanceDisplay.classList.remove("balance-increase", "balance-decrease");
    }, 500);
  }

  handleFetchResponse = (response) => {
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return response.json();
  };

  function handleTransaction(endpoint, amount) {
    if (amount && !isNaN(amount) && amount > 0) {
      fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify({ amount: amount }),
      })
        .then((response) => handleFetchResponse(response))
        .then((data) => {
          if (data.success) {
            updateBalance(data.newBalance);
          }
        });
    }
  }

  depositButton.addEventListener("click", function () {
    const amount = parseFloat(amountInput.value);
    handleTransaction("deposit", amount);
  });

  withdrawButton.addEventListener("click", function () {
    const amount = parseFloat(amountInput.value);
    handleTransaction("withdraw", amount);
  });

  closeButton.addEventListener("click", function () {
    fetch(`https://${GetParentResourceName()}/closeBank`, {
      method: "POST",
    }).catch((error) => {
      console.error("Error:", error);
    });
  });

  window.addEventListener("keyup", (e) => {
    if (e.key === "Escape") {
      fetch(`https://${GetParentResourceName()}/closeBank`, {
        method: "POST",
      }).catch((error) => {
        console.error("Error:", error);
      });
    }
  });
});
