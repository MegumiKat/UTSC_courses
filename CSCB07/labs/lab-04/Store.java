public abstract class Store {
    Deliver deliver;
    DeterSize size;
    public void setDeterSize(DeterSize size){
        this.size = size;
    }
    public void setDeliver(Deliver deliver){
        this.deliver = deliver;
    }
}
