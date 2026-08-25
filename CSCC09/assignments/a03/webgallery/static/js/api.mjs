/*  ******* Data types *******
    image objects must have at least the following attributes:
        - (String) _id 
        - (String) title
        - (String) author
        - (Date) date

    comment objects must have the following attributes
        - (String) _id
        - (String) imageId
        - (String) author
        - (String) content
        - (Date) date
****************************** */

// Generate a unique id for images and comments (if needed on the client-side)
function generateId() {
    return '_' + Math.random().toString(36).slice(2, 11);
}

// Get all images from the gallery
export function getImages(success, failure) {
    fetch('/api/images', {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
        }
    })
    .then(response => response.json())
    .then(data => success(data))
    .catch(error => failure(error));
}

// Get a specific image by imageId
export function getImage(imageId, success, failure) {
    fetch(`/api/images/${imageId}`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
        }
    })
    .then(response => response.json())
    .then(data => success(data))
    .catch(error => failure(error));
}

// Add an image to the gallery
export function addImage(title, author, file, success, failure) {
    const formData = new FormData();
    formData.append('title', title);
    formData.append('author', author);
    formData.append('file', file);

    fetch('/api/images', {
        method: 'POST',
        body: formData,
    })
    .then(response => response.json())
    .then(data => success(data))
    .catch(error => failure(error));
}

// Delete an image from the gallery given its imageId
export function deleteImage(imageId, callback) {
    fetch(`/api/images/${imageId}`, {
        method: 'DELETE',
    })
    .then(response => {
        if (response.ok) {
            callback(null);
        } else {
            callback('Error deleting image');
        }
    })
    .catch(error => callback(error));
}

// Get all comments for a specific image
export function getComments(imageId, success, failure) {
    fetch(`/api/comments?imageId=${imageId}`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
        }
    })
    .then(response => response.json())
    .then(data => success(data))
    .catch(error => failure(error));
}

// Add a comment to an image
export function addComment(imageId, author, content, success, failure) {
    const data = {
        imageId: imageId,
        author: author,
        content: content,
    };

    fetch('/api/comments', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    })
    .then(response => response.json())
    .then(data => success(data))
    .catch(error => failure(error));
}

// Delete a comment from an image
export function deleteComment(commentId, success, failure) {
    fetch(`/api/comments/${commentId}`, {
        method: 'DELETE',
    })
    .then(response => {
        if (response.ok) {
            success();
        } else {
            failure('Error deleting comment');
        }
    })
    .catch(error => failure(error));
}

export function getUsername() {
    return document.cookie.replace(
      /(?:(?:^|.*;\s*)username\s*\=\s*([^;]*).*$)|^.*$/,
      "$1",
    );
      // return sessionStorage.getItem("username") || null;
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

export function getUsers(success, failure) {
    fetch('/api/users', {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
        }
    })
    .then(response => response.json())
    .then(data => success(data))
    .catch(error => failure(error));
}

export function getGallary(success, failure) {
    fetch('/api/gallary', {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
        }
    })
    .then(response => response.json())
    .then(data => success(data))
    .catch(error => failure(error));
}