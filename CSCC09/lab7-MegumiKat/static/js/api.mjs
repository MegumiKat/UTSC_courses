export function getUsername() {
  return document.cookie.replace(
    /(?:(?:^|.*;\s*)username\s*\=\s*([^;]*).*$)|^.*$/,
    "$1",
  );
}

function handleReponse(res){
	if (res.status != 200) { return res.text().then(text => { throw new Error(`${text} (status: ${res.status})`)}); }
	return res.json();
}

export function signin(username, password, fail, success) {
    fetch("/signin/", {
  		method:  "POST",
  		headers: {"Content-Type": "application/json"},
  		body: JSON.stringify({ username, password }),
    })
	.then(handleReponse)
	.then(success)
	.catch(fail);
}

export function signup(username, password, fail, success) {
    fetch("/signup/", {
  		method:  "POST",
  		headers: {"Content-Type": "application/json"},
  		body: JSON.stringify({ username, password }),
    })
	.then(handleReponse)
	.then(success)
	.catch(fail);
}

export function getMessages(page, fail, success) {
  fetch(`/api/messages/?page=${page}`)
	.then(handleReponse)
	.then(success)
	.catch(fail);
}


export function addMessage(username, content, fail, success) {
    fetch("/api/messages/", {
  		method:  "POST",
  		headers: {"Content-Type": "application/json"},
  		body: JSON.stringify({ username, content }),
    })
	.then(handleReponse)
	.then(success)
	.catch(fail);
}

export function deleteMessage(messageId, fail, success) {
	fetch(`/api/messages/${messageId}/`, {
		method:  "DELETE",
	})
	.then(handleReponse)
	.then(success)
	.catch(fail);
}

export function upvoteMessage(messageId, fail, success) {
    fetch(`/api/messages/${messageId}/`, {
  		method:  "PATCH",
  		headers: {"Content-Type": "application/json"},
  		body: JSON.stringify({ action: "upvote" }),
    })
	.then(handleReponse)
	.then(success)
	.catch(fail);
}

export function downvoteMessage(messageId, fail, success) {
    fetch(`/api/messages/${messageId}/`, {
  		method:  "PATCH",
  		headers: {"Content-Type": "application/json"},
  		body: JSON.stringify({ action: "downvote" }),
    })
	.then(handleReponse)
	.then(success)
	.catch(fail);
}