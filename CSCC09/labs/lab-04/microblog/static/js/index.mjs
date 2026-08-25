import {
  getMessages,
  addMessage,
  deleteMessage,
  upvoteMessage,
  downvoteMessage,
} from "./api.mjs";

function updateVotes(message) {
  document.querySelector("#msg" + message.id + " .upvote-icon").innerHTML =
    message.upvote;
  document.querySelector("#msg" + message.id + " .downvote-icon").innerHTML =
    message.downvote;
}

async function updateMessages() {
  document.querySelector("#messages").innerHTML = "";
  const messages = await getMessages();
  messages.forEach(function (message) {
    const elmt = document.createElement("div");
    elmt.className = "row message align-items-center";
    elmt.id = "msg" + message.id;
    elmt.innerHTML = `
        <div class="col-1 message-user">
          <img
            class="message-picture"
            src="media/user.png"
            alt="${message.author}"
          />
          <div class="message-username">${message.author}</div>
        </div>
        <div class="col-auto message-content">
          ${message.content}
        </div>
        <div class="col-1 upvote-icon icon">${message.upvote}</div>
        <div class="col-1 downvote-icon icon">${message.downvote}</div>
        <div class="col-1 delete-icon icon"></div>
      `;
    elmt.querySelector(".delete-icon").addEventListener("click", async function () {
      await deleteMessage(message.id);
      updateMessages();
    });
    elmt.querySelector(".upvote-icon").addEventListener("click", async function () {
      const updateMessage = await upvoteMessage(message.id);
      updateVotes(updateMessage);
    });
    elmt.querySelector(".downvote-icon").addEventListener("click", async function () {
      const updateMessage = await downvoteMessage(message.id);
      updateVotes(updateMessage);
    });
    document.querySelector("#messages").prepend(elmt);
  });
}

document
  .querySelector("#create-message-form")
  .addEventListener("submit", async function (e) {
    e.preventDefault();
    const author = document.getElementById("post-username").value;
    const content = document.getElementById("post-content").value;
    document.getElementById("create-message-form").reset();
   
    const newMessage = await addMessage(author, content);
    
   
    const newMessageElement = createMessageElement(newMessage); 
    document.querySelector("#messages").prepend(newMessageElement); 
  });



  function createMessageElement(message) {
    const elmt = document.createElement("div");
    elmt.className = "row message align-items-center";
    elmt.id = "msg" + message.id;
    elmt.innerHTML = `
          <div class="col-1 message-user">
            <img
              class="message-picture"
              src="media/user.png"
              alt="${message.author}"
            />
            <div class="message-username">${message.author}</div>
          </div>
          <div class="col-auto message-content">
            ${message.content}
          </div>
          <div class="col-1 upvote-icon icon">${message.upvote}</div>
          <div class="col-1 downvote-icon icon">${message.downvote}</div>
          <div class="col-1 delete-icon icon"></div>
        `;
    elmt.querySelector(".delete-icon").addEventListener("click", async function () {
      await deleteMessage(message.id);
      updateMessages(); 
    });
    elmt.querySelector(".upvote-icon").addEventListener("click", async function () {
      const updatedMessage = await upvoteMessage(message.id);
      updateVotes(updatedMessage); 
    });
    elmt.querySelector(".downvote-icon").addEventListener("click", async function () {
      const updatedMessage = await downvoteMessage(message.id);
      updateVotes(updatedMessage); 
    });
    return elmt;
  }

  updateMessages();

  setInterval(updateMessages, 2000);