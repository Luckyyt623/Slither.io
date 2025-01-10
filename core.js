const noButton = document.getElementById("no-button");

noButton.addEventListener("mouseover", () => {
  // Generate random positions within the window
  const x = Math.random() * (window.innerWidth - noButton.offsetWidth);
  const y = Math.random() * (window.innerHeight - noButton.offsetHeight);

  // Apply the new position
  noButton.style.position = "absolute";
  noButton.style.left = `${x}px`;
  noButton.style.top = `${y}px`;
});
