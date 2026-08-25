function handleResponse(res){
	if (res.status != 200) { return res.text().then(text => { throw new Error(`${text} (status: ${res.status})`)}); }
	return res.json();
}

export function addMessage(username, content, fail, success) {
    fetch("/api/messages/", {
		method: "POST",
		body: JSON.stringify({ username: username, content: content }),
	    headers: {"Content-Type": "application/json"},
    })
    .then(handleResponse)
    .then(success)
    .catch(fail);
}

export function deleteMessage(messageId, fail, success) {
  fetch("/api/messages/" + messageId + "/", {
	  method: "DELETE"
  })
  .then(handleResponse)
  .then(success)
  .catch(fail);
}

export function upvoteMessage(messageId, fail, success) {
    fetch("/api/messages/" + messageId + "/", {
		method: "PATCH",
		body: JSON.stringify({ action: "upvote" }),
	    headers: {"Content-Type": "application/json"},
    })
    .then(handleResponse)
    .then(success)
    .catch(fail);
}

export function downvoteMessage(messageId, fail, success) {
    fetch("/api/messages/" + messageId + "/", {
		method: "PATCH",
		body: JSON.stringify({ action: "downvote" }),
	    headers: {"Content-Type": "application/json"},
    })
    .then(handleResponse)
    .then(success)
    .catch(fail);
}

export function getMessages(page, fail, success) {
  fetch(`/api/messages/?page=${page}`)
    .then(handleResponse)
    .then(success)
    .catch(fail);
}

export function getUsers(fail, success) {
  fetch("/api/users/")
    .then(handleResponse)
    .then(success)
    .catch(fail);
}
