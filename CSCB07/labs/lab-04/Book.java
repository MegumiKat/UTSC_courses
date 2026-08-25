public class Book extends Item {
	String isbn;
	String title;
	double length;
	double width;
	double height;
	
	public Book(String isbn, String title, double length, double width, double height) {
		this.isbn = isbn;
		this.title = title;
		this.length = length;
		this.width = width;
		this.height = height;
	}

	@Override
	public double getLength() {
		return length;
	}

	@Override
	public double getHeight() {
		return height;
	}

	@Override
	public double getWidth() {
		return width;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((isbn == null) ? 0 : isbn.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (!(obj instanceof Book))
			return false;
		Book other = (Book) obj;
		if (isbn == null) {
			if (other.isbn != null)
				return false;
		} else if (!isbn.equals(other.isbn))
			return false;
		return true;
	}

	@Override
	public String toString() {
		return title;
	}
}
