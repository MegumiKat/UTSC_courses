function handleReponse(res){
	if (res.status != 200) { return res.text().then(text => { throw new Error(`${text} (status: ${res.status})`)}); }
	return res.json();
}

export function getMessages(page) {
  return fetch(`/api/messages/?page=${page}`).then(handleReponse)
}

export function addMessage(username, content) {
    return fetch("/api/messages/", {
  		method:  "POST",
  		headers: {"Content-Type": "application/json"},
  		body: JSON.stringify({ username, content }),
    }).then(handleReponse)
}

export function deleteMessage(messageId) {
	return fetch(`/api/messages/${messageId}/`, {
		method:  "DELETE",
	}).then(handleReponse)
}

export function upvoteMessage(messageId) {
    return fetch(`/api/messages/${messageId}/`, {
  		method:  "PATCH",
  		headers: {"Content-Type": "application/json"},
  		body: JSON.stringify({ action: "upvote" }),
    }).then(handleReponse)
}

export function downvoteMessage(messageId) {
    return fetch(`/api/messages/${messageId}/`, {
  		method:  "PATCH",
  		headers: {"Content-Type": "application/json"},
  		body: JSON.stringify({ action: "downvote" }),
    }).then(handleReponse)
}