import * as api from "./api.mjs";
import {getUsername} from "./api.mjs";

const username = getUsername();

// Handle errors
function onError(err) {
    console.error("[error]", err);
    const errorBox = document.querySelector("#error_box");
    if (errorBox) {
        errorBox.innerHTML = err.message;
        errorBox.style.visibility = "visible";
    }
}

// Render user cards
function renderUserCard(user) {
    const userCard = document.createElement("div");
    userCard.classList.add("user-card");
    userCard.innerHTML = `
        <h2>${user._id}</h2>
    `;
    userCard.addEventListener("click", () => {
        window.location.href = `/individualGallary.html?userId=${user._id}`;
    });
    return userCard;
}

// Load all users and render them as cards
function loadAllUsers() {
    const userListContainer = document.getElementById("userList");
    if (!userListContainer) {
        console.error("User list container not found.");
        return;
    }

    api.getUsers(
        (users) => {
            userListContainer.innerHTML = ""; // Clear previous users
            users.forEach((user) => {
                // console.log("User Object:", user);
                const userCard = renderUserCard(user);
                userListContainer.appendChild(userCard);
            });
        },
        (error) => onError(error)
    );
}

document.querySelector("#signin_button").style.visibility = username
    ? "hidden"
    : "visible";
document.querySelector("#signout_button").style.visibility = username
    ? "visible"
    : "hidden";
document.querySelector("#userList").style.visibility = username
    ? "visible"
    : "hidden";


// Initialize the page and load all users
document.addEventListener("DOMContentLoaded", function () {
    loadAllUsers();
});