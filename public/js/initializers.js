document.addEventListener("DOMContentLoaded", function () {
  initializePopups();
  setupInitialApiCodeBlock();

  function initializePopups() {
    $(".popup").popup();
  }

  function setupInitialApiCodeBlock() {
    const json = {
      input: { content_type: "people", properties: [] },
      data_expiration_hours: "4 hours",
      cached: true,
      time_to_expiration: "Some time in the future",
      data: {
        people: [
          { id: 1, name: "John Doe", age: 25, city: "New York" },
          { id: 2, name: "Jane Smith", age: 30, city: "Los Angeles" },
          { id: 3, name: "John Smith", age: 35, city: "Chicago" },
        ],
      },
    };
    const codeBlock = document.getElementById("api-code-block");

    codeBlock.textContent = JSON.stringify(json, undefined, 2);

    Prism.highlightAll();
  }
});
