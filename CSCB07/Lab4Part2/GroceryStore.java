import java.util.HashSet;

public class GroceryStore extends Store {
	
	HashSet<GroceryItem> items;

	
	public GroceryStore() {
		items = new HashSet<GroceryItem>();
		this.deliver = new DeliverForGrocery();
		this.size = new DeterminBoxSize();
	}
	
	public void addItem(GroceryItem item) {
		items.add(item);
	}
	
	public void removeItem(GroceryItem item) {
		items.remove(item);
	}
	
	public boolean itemExists(GroceryItem item) {
		return items.contains(item);
	}
	
	String determineBoxSize(GroceryItem item) {
		double length = item.getLength();
		double width = item.getWidth();
		double height = item.getHeight();
		double max = length;
		if(max < width)
			max = width;
		if(max < height)
			max = height;
		return size.determineBoxSize(max);
	}
	
	void deliver(GroceryItem item, Customer customer) {
		String size = determineBoxSize(item);
		if(itemExists(item)){
			deliver.deliver(item, customer, size);
			removeItem(item);
		}
	}

}
