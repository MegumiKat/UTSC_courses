public class EBook extends Item {
	String isbn;
	String title;
	public EBook(String isbn, String title) {
		this.isbn = isbn;
		this.title = title;
	}

	@Override
	public double getLength() {
		throw new RuntimeException();
	}

	@Override
	public double getHeight() {
		throw new RuntimeException();
	}

	@Override
	public double getWidth() {
		throw new RuntimeException();
	}

}
