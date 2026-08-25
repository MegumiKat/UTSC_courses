public class DeliverForGrocery implements Deliver{
    @Override
    public void deliver(Item item, Customer customer, String size) {
            System.out.println("Delivering " + item);
            System.out.println("Delivery service: Groceries Express");
            System.out.println("Box size: " + size);
            System.out.println("Address: " + customer.getPostalCode());
    }
}
