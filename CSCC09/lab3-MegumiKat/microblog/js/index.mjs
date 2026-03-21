import { getMessages, addMessage, deleteMessage } from './api.mjs';

// function pullFromLocalStorage() {
//   const author = localStorage.getItem("post_name");
//   const comment = localStorage.getItem("post_content");
//   document.getElementById("post_name").value = author ? author : "";
//   document.getElementById("post_content").value = comment ? comment : "";

//   const msg = JSON.parse(localStorage.getItem("messages")) || [];
//   msg.forEach(renderMessage);
// }

// function pushauthorToLocalStorage(e) {
//   const author = document.getElementById("post_name").value;
//   localStorage.setItem("post_name", author);
// }

// function pushCommentToLocalStorage(e) {
//   const content = document.getElementById("post_content").value;
//   localStorage.setItem("post_content", content);
// }

// function clearLocalStorage() {
//   localStorage.removeItem("post_name");
//   localStorage.removeItem("post_content");
//   localStorage.removeItem("messages");
//   document.getElementById("messages").innerHTML = "";
//   pullFromLocalStorage();
// }

// function updateLocalStorage(author, content, upvotes, downvotes) {
//   const messages = JSON.parse(localStorage.getItem("messages")) || [];
//   const updateMessage = messages.map((msg) => {
//     if (msg.author === author && msg.content === content) {
//       return { author, content, upvotes, downvotes };
//     }
//     return msg;
//   });
//   localStorage.setItem("messages", JSON.stringify(updateMessage));
// }

// function deleteMessage(author, content) {
//   const messages = JSON.parse(localStorage.getItem("messages")) || [];
//   const updateMessage = messages.filter(
//     (msg) => !(msg.author == author && msg.content == content));
//   localStorage.setItem("messages", JSON.stringify(updateMessage));
// }

function updateMessageInStorage(updatedMessage) {
  const messages = getMessages();
  const messageIndex = messages.findIndex(msg => msg.messageId === updatedMessage.messageId);
  if (messageIndex !== -1) {
    messages[messageIndex] = updatedMessage;  // Update the message
    localStorage.setItem("messages", JSON.stringify(messages));  // Save back to localStorage
  }
}

function loadMessages() {
  const messages = getMessages();
  messages.forEach(renderMessage);
}


function renderMessage(message) {
  const elmt = document.createElement("div");
  elmt.className = "message";
  elmt.innerHTML = `
        <div class="message_user">
            <img class="message_picture" src="media/user.png" alt="${message.author}">
            <div class="message_author">${message.author}</div>
        </div>
        <div class="message_content">${message.content}</div>
        <div class="upvote-icon icon">${message.upvotes}</div>
        <div class="downvote-icon icon">${message.downvotes}</div>
        <div class="delete-icon icon"></div>
    `;


  const upvote = elmt.querySelector('.upvote-icon');
  const downvote = elmt.querySelector('.downvote-icon');
  const deleteIcon = elmt.querySelector('.delete-icon');

  upvote.addEventListener('click', function () {
    message.upvotes += 1;
    upvote.textContent = message.upvotes;
    console.log('upvote count:', upvote.textContent);
    updateMessageInStorage(message);
  })

  downvote.addEventListener('click', function (e) {
    // let target = e.target;
    message.downvotes += 1;
    downvote.textContent = message.downvotes;
    // target.style.color = 'red';
    console.log('downvote count', downvote.textContent);
    updateMessageInStorage(message);
  })

  deleteIcon.addEventListener('click', function () {
    elmt.remove();
    deleteMessage(message.messageId);
  })

  // add this element to the document
  document.getElementById("messages").prepend(elmt);
}

document
  .getElementById("create_message_form")
  .addEventListener("submit", function (e) {
    // prevent from refreshing the page on submit
    e.preventDefault();
    // read form elements
    const author = document.getElementById("post_name").value;
    const content = document.getElementById("post_content").value;
    const message = addMessage(author, content);
    // clean form
    document.getElementById("create_message_form").reset();
    // create a new message element
    renderMessage(message);
  });


loadMessages();
