class Trier<T> {
  final T? Function() onInvoke;

  const Trier(this.onInvoke);

  T? get invoke {
    try {
      return onInvoke.call();
    } catch (_) {
      return null;
    }
  }
}
