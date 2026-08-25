let database = [];
const API_URL = 'http://localhost:3000/api/messages/';
let id = 0;

let Message = function (author, content) {
  this.id = id++;
  this.author = author;
  this.content = content;
  this.upvote = 0;
  this.downvote = 0;
};

/*  
******* Data types *******
Message:
  Attributes:
    - (string) messageId 
    - (string) author
    - (string) content
    - (number) upvote
    - (number) downvote 
*/

// export function addMessage(author, content) {
//   let message = new Message(author, content);
//   database.unshift(message);
// }

export async function addMessage(author, content) {
  const response = await fetch(API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ author, content }),
  });

  if (!response.ok) {
    console.error('Failed to add message:', response.statusText);
    return;
  }

  const message = await response.json();
  return message;
}




// export function deleteMessage(messageId) {
//   let index = database.findIndex(function (message) {
//     return message.id === messageId;
//   });
//   if (index === -1) return null;
//   database.splice(index, 1);
// }


export async function deleteMessage(messageId) {
  const response = await fetch(`${API_URL}${messageId}/`, {
    method: 'DELETE',
  });

  if (!response.ok) {
    console.error('Failed to delete message:', response.statusText);
    return;
  }

  const deletedMessage = await response.json();
  return deletedMessage;
}






// export function upvoteMessage(messageId) {
//   let message = database.find(function (message) {
//     return message.id === messageId;
//   });
//   message.upvote += 1;
// }



export async function upvoteMessage(messageId) {
  const response = await fetch(`${API_URL}${messageId}/`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ action: 'upvote' }),
  });

  if (!response.ok) {
    console.error('Failed to upvote message:', response.statusText);
    return;
  }

  const message = await response.json();
  return message;
}




// export function downvoteMessage(messageId) {
//   let message = database.find(function (message) {
//     return message.id === messageId;
//   });
//   message.downvote += 1;
// }

export async function downvoteMessage(messageId) {
  const response = await fetch(`${API_URL}${messageId}/`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ action: 'downvote' }),
  });

  if (!response.ok) {
    console.error('Failed to downvote message:', response.statusText);
    return;
  }

  const message = await response.json();
  return message;
}








// export function getMessages() {
//   return database;
// }

export async function getMessages() {
  const response = await fetch(API_URL);

  if (!response.ok) {
    console.error('Failed to fetch messages:', response.statusText);
    return [];
  }

  const data = await response.json();
  return data.messages;
}