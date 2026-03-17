const dino = document.getElementById("dino");
const cactus = document.getElementById("cactus");
const scoreElement = document.getElementById("score");
const gameOverElement = document.getElementById("game-over");

let isJumping = false;
let score = 0;
let isGameOver = false;

document.addEventListener("keydown", function(event) {
    if (event.code === "Space" || event.code === "ArrowUp") {
        if (isGameOver) {
            resetGame();
        } else {
            jump();
        }
    }
});

// For touch devices
document.addEventListener("touchstart", function() {
    if (isGameOver) {
        resetGame();
    } else {
        jump();
    }
});

function jump() {
    if (!dino.classList.contains("jump") && !isGameOver) {
        dino.classList.add("jump");
        isJumping = true;

        setTimeout(function() {
            dino.classList.remove("jump");
            isJumping = false;
        }, 500);
    }
}

function resetGame() {
    isGameOver = false;
    score = 0;
    scoreElement.innerText = score;
    gameOverElement.classList.add("hidden");

    // reset cactus position by restarting animation
    cactus.classList.remove("move");
    void cactus.offsetWidth; // trigger reflow
    cactus.classList.add("move");
    cactus.style.animationPlayState = "running";
}

let checkAlive = setInterval(function() {
    if (isGameOver) return;

    // get current dino Y position
    let dinoTop = parseInt(window.getComputedStyle(dino).getPropertyValue("top"));

    // get current cactus X position
    let cactusLeft = parseInt(window.getComputedStyle(cactus).getPropertyValue("left"));

    // detect collision
    // dino left is 50, width is 40 (span 50 to 90)
    // cactus width is 20. Intersects if cactus is between 30 and 90
    // ground is 158. dino bottom when on ground is 198.
    // cactus is height 40, top 158. If dino top + 40 > 158 => dino top > 118
    if (cactusLeft < 90 && cactusLeft > 30 && dinoTop > 118) {
        // collision
        isGameOver = true;

        // stop animation
        cactus.style.animationPlayState = "paused";
        dino.style.animationPlayState = "paused";

        // show game over
        gameOverElement.classList.remove("hidden");
    }
}, 10);

setInterval(function() {
    if (!isGameOver) {
        score++;
        scoreElement.innerText = ("00000" + score).slice(-5);
    }
}, 100);

// Start movement initially
cactus.classList.add("move");
