import {
  getMessages,
  addMessage,
  deleteMessage,
  upvoteMessage,
  downvoteMessage,
  getUsername,
} from "./api.mjs";

function sanitizeInput(input) {
  const div = document.createElement('div');
  div.textContent = input; // make raw text
  return div.innerHTML; 
}

function onError(err) {
  console.error("[error]", err);
  const error_box = document.querySelector("#error_box");
  error_box.innerHTML = err.message;
  error_box.style.visibility = "visible";
}

function updateVotes(message) {
  document.querySelector("#msg" + message._id + " .upvote-icon").innerHTML =
    message.upvote;
  document.querySelector("#msg" + message._id + " .downvote-icon").innerHTML =
    message.downvote;
}

function updateMessages() {
  document.querySelector("#messages").innerHTML = "";
  getMessages(0, onError, function (messages) {
    messages.forEach(function (message) {
      const elmt = document.createElement("div");
      elmt.className = "message";
      elmt.id = "msg" + message._id;
      elmt.innerHTML = `
                <div class="message_user">
                    <img class="message_picture" src="media/user.png" alt="${message.username}">
                    <div class="message_username">${message.username}</div>
                </div>
                <div class="message_content">${message.content}</div>
                <div class="upvote-icon icon">${message.upvote}</div>
                <div class="downvote-icon icon">${message.downvote}</div>
                <div class="delete-icon icon"></div>
            `;
      elmt.querySelector(".delete-icon").addEventListener("click", function () {
        deleteMessage(message._id, onError, updateMessages); 
      });
      elmt.querySelector(".upvote-icon").addEventListener("click", function () {
        upvoteMessage(message._id, onError, function (msg) {
          return updateVotes(msg);
        });
      });
      elmt
        .querySelector(".downvote-icon")
        .addEventListener("click", function () {
          downvoteMessage(message._id, onError, function (msg) {
            return updateVotes(msg);
          });
        });
      document.querySelector("#messages").prepend(elmt);
    });
  });
}

const username = getUsername();
document.querySelector("#signin_button").style.visibility = username
  ? "hidden"
  : "visible";
document.querySelector("#signout_button").style.visibility = username
  ? "visible"
  : "hidden";
document.querySelector("#create_message_form").style.visibility = username
  ? "visible"
  : "hidden";

if (username) {
  updateMessages();
  document
    .querySelector("#create_message_form")
    .addEventListener("submit", function (e) {
      e.preventDefault();
      const content = document.querySelector("#post_content").value;
      const sanitizedContent = sanitizeInput(content);
      document.getElementById("create_message_form").reset();
      addMessage(username, sanitizedContent, onError, updateMessages);
    });
}
