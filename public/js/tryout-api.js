document.addEventListener("DOMContentLoaded", function () {
  const apiSubmitForm = document.getElementById("api-form");
  const propertyParamInput = document.querySelector("#property-param-value");
  const keyParamInput = document.querySelector("#key-param-value");
  const apiEndpointInput = document.querySelector("#api-endpoint");

  const toggleDisabled = (button, input, disabled) => {
    button.disabled = disabled;
    input.disabled = disabled;
  };

  const updateEndpoint = (param, value) => {
    const apiEndpointValue = apiEndpointInput.value;
    const params = apiEndpointValue.split("?")[1];
    const urlSearchParams = new URLSearchParams(params);

    if (!value) {
      urlSearchParams.delete(param);
    } else {
      urlSearchParams.set(param, value);
    }

    const baseUrl = apiEndpointValue.split("?")[0];
    const searchParams = decodeURIComponent(urlSearchParams.toString());
    apiEndpointInput.value = searchParams
      ? `${baseUrl}?${searchParams}`
      : baseUrl;
  };

  const handleInput = (input, param) => {
    input.addEventListener("input", (e) => {
      updateEndpoint(param, e.target.value);
    });
  };

  const writeRateLimitSessionWarning = () => {
    let rateLimitCount = sessionStorage.getItem("rateLimitCount") || 0;
    rateLimitCount++;
    sessionStorage.setItem("rateLimitCount", rateLimitCount);
  };

  const checkRateLimitApproaching = () => {
    const rateLimitCount = sessionStorage.getItem("rateLimitCount") || 0;
    if (rateLimitCount >= 5) {
      new Notify({
        status: "info",
        title: "Rate limit warning",
        text: "You're approaching the API's rate limit. Be careful with your requests.",
      });
    }
  };

  apiEndpointInput.addEventListener("input", (e) => {
    const inputEmpty = e.target.value === "";
    propertyParamInput.disabled = inputEmpty;
    keyParamInput.disabled = inputEmpty;
  });

  handleInput(propertyParamInput, "property");
  handleInput(keyParamInput, "key");

  apiSubmitForm.addEventListener("submit", async (e) => {
    e.preventDefault();

    checkRateLimitApproaching();

    const submitButton = e.target.querySelector("button");
    const contentInput = document.querySelector("#api-endpoint");
    const codeBlock = document.getElementById("api-code-block");

    if (!contentInput.value) {
      return new Notify({
        status: "error",
        title: "Error",
        text: "Please enter an API endpoint.",
      });
    }

    codeBlock.textContent =
      "Loading... If this endpoint is uncached, it will take a few moments to generate the data";

    submitButton.classList.add("loading");
    toggleDisabled(submitButton, contentInput, true);

    try {
      const response = await fetch(`/api/${contentInput.value}`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (response.status === 429) {
        throw new Error("Rate limit exceeded");
      }

      const data = await response.json();
      codeBlock.textContent = JSON.stringify(data, undefined, 2);
      Prism.highlightAll();

      if (!data.cached && data.status === 200) {
        writeRateLimitSessionWarning();
      }
    } catch (error) {
      new Notify({
        status: "error",
        title: "Error",
        text: "An error occurred while fetching the API: " + error,
      });
    } finally {
      submitButton.classList.remove("loading");
      toggleDisabled(submitButton, contentInput, false);
    }
  });
});
