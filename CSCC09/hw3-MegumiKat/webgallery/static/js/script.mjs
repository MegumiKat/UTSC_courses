import {
    addImage,
    deleteImage,
    addComment,
    deleteComment,
    getImages,
    getComments,
    getUsername,
    getImage,
    getUsers
} from './api.mjs';

let currentImageIndex = 0;
let currentPage = 1;
const commentsPerPage = 10;

const urlParams = new URLSearchParams(window.location.search);
const userId = urlParams.get('userId');
// console.log(userId);

const imageAdding = document.getElementById('imageAdding');
const addImageForm = document.getElementById('addImageForm');
const imageForm = document.getElementById('imageForm');
const currentImageContainer = document.getElementById('currentImageContainer');
const currentImage = document.getElementById('currentImage');
const currentTitle = document.getElementById('currentTitle');
const currentAuthor = document.getElementById('currentAuthor');
const prevImageBtn = document.getElementById('prevImage');
const nextImageBtn = document.getElementById('nextImage');
const deleteImageBtn = document.getElementById('deleteImage');
const imageDisplay = document.getElementById('imageDisplay');

// Modal elements for comments and adding images
const commentModal = document.getElementById('commentModal');
const modalTitle = document.getElementById('modalImageTitle');
const modalCommentsList = document.getElementById('modalCommentsList');
const modalCommentForm = document.getElementById('modalCommentForm');
const modalCommentAuthor = document.getElementById('modalCommentAuthor');
const modalCommentContent = document.getElementById('modalCommentContent');
const closeModalBtn = document.getElementById('closeModal');
const closeFormBtn = document.getElementById('closeForm');
const submitFormBtn = document.getElementById('submitForm');
const submitCommentBtn = document.getElementById('submitComment');
const backToGalleryBtn = document.getElementById('backToGallery');

const username = getUsername();
// console.log(username);

// Pagination elements
const paginationControls = document.getElementById('paginationControls');
const prevPageBtn = document.getElementById('prevPage');
const nextPageBtn = document.getElementById('nextPage');

imageAdding.addEventListener('click', () => {
    addImageForm.classList.remove('hidden');
    addImageForm.style.display = 'block';
});

backToGalleryBtn.addEventListener('click', () => {
    window.location.href = '/';
});


function loadAllImages() {
    getImage(userId,
        (images) => {
            if (images.length > 0) {
                currentImageIndex = images.length - 1;
                // console.log("222222   " + images.length);
                // console.log("333333    " + currentImageIndex);
                loadImage(currentImageIndex);
                document.querySelector('.imageDisplay').style.display = 'flex';
            } else {
                document.querySelector('.imageDisplay').style.display = 'none';
            }
        },
        (error) => console.error("Failed to load images:", error)
    );
}


submitFormBtn.addEventListener('click', (e) => {
    e.preventDefault();
    const title = document.getElementById('imageTitle').value;
    // console.log("444444" + title);
    const author = username;
    const file = document.getElementById('imageFile').files[0];

    if (!title || !author || !file) {
        alert('Fill all blank');
        return;
    }


    const formData = new FormData();
    formData.append('title', title);
    formData.append('author', author);
    formData.append('file', file);

    addImage(
        title,
        author,
        file,
        (image) => {
            // console.log("111111" + image.url);
            loadAllImages();
            addImageForm.style.display = 'none';
            imageForm.reset();
        },
        (error) => console.error('Failed adding:', error)
    );
});


function loadImage(index) {
    getImage(userId,
        (images) => {
            if (images.length === 0) {
                document.querySelector('.imageDisplay').style.display = 'none';
                return;
            }
            const image = images[index];
            // console.log(image.url);
            currentImage.src = image.url;

            currentTitle.textContent = image.title;
            currentAuthor.textContent = `By: ${image.author}`;
        },
        (error) => console.error('Fail loading image', error)
    );
}


deleteImageBtn.addEventListener('click', () => {
    getImage(userId,
        (images) => {
            const image = images[currentImageIndex];
            const imageId = image._id;

            // 判断是否可以删除该图片
            if (username === userId || image.author === username) {
                deleteImage(imageId,
                    () => {
                        if (images.length > 1) {
                            currentImageIndex = currentImageIndex > 0 ? currentImageIndex - 1 : 0;
                        }
                        loadAllImages();
                    },
                    (error) => console.error('failed deleting:', error)
                );
            } else {
                // console.error('You do not have permission to delete this image');
                alert('You do not have permission to delete this image.');
            }
        },
        (error) => console.error('failed to get list when deleting', error)
    );
});


prevImageBtn.addEventListener('click', () => {
    getImage(userId, (images) => {

        if (currentImageIndex === 0) {
            currentImageIndex = images.length - 1;
        } else {
            currentImageIndex--;
        }
        loadImage(currentImageIndex);
    });
});

nextImageBtn.addEventListener('click', () => {
    getImage(userId, (images) => {

        if (currentImageIndex === images.length - 1) {
            currentImageIndex = 0;
        } else {
            currentImageIndex++;
        }
        loadImage(currentImageIndex);
    });
});


currentImage.addEventListener('click', () => {
    openCommentModal(currentImageIndex);
});


function openCommentModal(index) {
    getImages(
        (images) => {
            const image = images[index];
            modalTitle.textContent = "Image Title  " + image.title;
            currentPage = 1;
            loadCommentsForModal(image._id);
            commentModal.classList.remove('hidden');
            commentModal.style.display = 'block';
        },
        (error) => console.error('fail loading', error)
    );
}


function loadCommentsForModal(imageId) {
    getComments(
        imageId,
        (comments) => {
            comments.sort((a, b) => new Date(b.date) - new Date(a.date));

            const totalPages = Math.ceil(comments.length / commentsPerPage);
            const start = (currentPage - 1) * commentsPerPage;
            const end = start + commentsPerPage;
            const paginatedComments = comments.slice(start, end);

            modalCommentsList.innerHTML = '';

            paginatedComments.forEach(comment => {
                const commentDiv = document.createElement('div');
                commentDiv.classList.add('comment');
                commentDiv.innerHTML = `
                    <p><strong>${comment.author}</strong> (${new Date(comment.date).toLocaleString()}):</p>
                    <p>${comment.content}</p>
                    
                `;

                const deleteBtn = document.createElement('div');
                deleteBtn.classList.add('deleteCommentBtn', 'icon');
                deleteBtn.setAttribute('data-id', comment._id);

                // 如果 username 等于 userId 或者评论是当前用户的，显示删除按钮
                if (username === userId || comment.author === username) {
                    commentDiv.appendChild(deleteBtn); // 只有有权删除时才显示按钮
                }
                modalCommentsList.appendChild(commentDiv);
            });

            document.querySelectorAll('.deleteCommentBtn').forEach(button => {
                button.addEventListener('click', (e) => {
                    const commentId = e.target.getAttribute('data-id');
                    deleteComment(
                        commentId,
                        () => loadCommentsForModal(imageId),
                        (error) => console.error('fail deleting comment', error)
                    );
                });
            });

            prevPageBtn.disabled = currentPage === 1;
            nextPageBtn.disabled = currentPage === totalPages;
        },
        (error) => console.error('fail loading comment:', error)
    );
}


submitCommentBtn.addEventListener('click', (e) => {
    e.preventDefault();
    const author = modalCommentAuthor.value;
    const content = modalCommentContent.value;
    getImages((images) => {
        const imageId = images[currentImageIndex]._id;

        if (!content || !author) {
            alert('Fill all blank');
            return;
        }

        addComment(
            imageId,
            author,
            content,
            () => {
                loadCommentsForModal(imageId);
                modalCommentForm.reset();
            },
            (error) => console.error('fail adding comment:', error)
        );
    });
});


closeModalBtn.addEventListener('click', () => {
    commentModal.style.display = 'none';
});

closeFormBtn.addEventListener('click', () => {
    addImageForm.style.display = 'none';
});


prevPageBtn.addEventListener('click', () => {
    if (currentPage > 1) {
        currentPage--;
        getImages((images) => {
            loadCommentsForModal(images[currentImageIndex]._id);
        });
    }
});

nextPageBtn.addEventListener('click', () => {
    getImages((images) => {
        const comments = getComments(images[currentImageIndex]._id);
        const totalPages = Math.ceil(comments.length / commentsPerPage);
        if (currentPage < totalPages) {
            currentPage++;
            loadCommentsForModal(images[currentImageIndex]._id);
        }
    });
});


document.querySelector("#signin_button").style.visibility = username
    ? "hidden"
    : "visible";
document.querySelector("#signout_button").style.visibility = username
    ? "visible"
    : "hidden";
document.querySelector("#imageAdding").style.visibility = (username === userId)
    ? "visible"
    : "hidden";
document.querySelector("#imageDisplay").style.visibility = username
    ? "visible"
    : "hidden";


loadAllImages();