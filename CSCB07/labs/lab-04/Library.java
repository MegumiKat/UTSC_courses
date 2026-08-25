import java.util.HashSet;

public class Library extends Store{
	
	HashSet<Book> books;
	
	public Library() {
		books = new HashSet<Book>();
		this.deliver = new DeliverForBook();
		this.size = new DeterBookSize();
	}
	
	public void addBook(Book book) {
		books.add(book);
	}
	
	public void removeBook(Book book) {
		books.remove(book);
	}
	
	public boolean bookExists(Book book) {
		return books.contains(book);
	}
	
	String determineBoxSize(Book book) {
		double length = book.getLength();
		double width = book.getWidth();
		double height = book.getHeight();
		double max = length;
		if(max < width)
			max = width;
		if(max < height)
			max = height;
		return size.determineBoxSize(max);
	}
	
	void deliver(Book book, Customer customer) {
		String size = determineBoxSize(book);
		if(bookExists(book)){
			deliver.deliver(book, customer, size);
			removeBook(book);
		}
	}

}
