import { addImage, deleteImage, addComment, deleteComment, getImages, getComments } from './api.mjs';

let currentImageIndex = 0;
let currentPage = 1;
const commentsPerPage = 10;

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

// Pagination elements
const paginationControls = document.getElementById('paginationControls');
const prevPageBtn = document.getElementById('prevPage');
const nextPageBtn = document.getElementById('nextPage');

imageAdding.addEventListener('click', () => {
    addImageForm.classList.remove('hidden');
    addImageForm.style.display = 'block';
});


function loadAllImages() {
    getImages(
        (images) => {
            if (images.length > 0) {
                currentImageIndex = images.length - 1;
                console.log("222222   " + images.length);
                console.log("333333    " + currentImageIndex);
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
    const author = document.getElementById('imageAuthor').value;
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
            console.log("111111" + image.url);
            loadAllImages();  
            addImageForm.style.display = 'none';
            imageForm.reset();
        },
        (error) => console.error('Failed adding:', error)
    );
});


function loadImage(index) {
    getImages(
        (images) => {
            if (images.length === 0) {
                document.querySelector('.imageDisplay').style.display = 'none';
                return;
            }
            const image = images[index];
            console.log(image.url);
            currentImage.src = image.url;

            currentTitle.textContent = image.title;
            currentAuthor.textContent = `By: ${image.author}`;
        },
        (error) => console.error('Fail loading image', error)
    );
}


deleteImageBtn.addEventListener('click', () => {
    getImages(
        (images) => {
            const imageId = images[currentImageIndex]._id; 
            deleteImage(imageId,
                () => {
                    if (images.length > 1) {
                        currentImageIndex = currentImageIndex > 0 ? currentImageIndex - 1 : 0;
                    }
                    loadAllImages();
                },
                (error) => console.error('failed deleting:', error)
            );
        },
        (error) => console.error('failed to get list when deleting', error)
    );
});


prevImageBtn.addEventListener('click', () => {
    getImages((images) => {
        
        if (currentImageIndex === 0) {
            currentImageIndex = images.length - 1;  
        } else {
            currentImageIndex--;  
        }
        loadImage(currentImageIndex);
    });
});

nextImageBtn.addEventListener('click', () => {
    getImages((images) => {
        
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
                    <div class="deleteCommentBtn icon" data-id="${comment._id}"></div>
                `;
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

loadAllImages();