bool nullOrEmpty(String text) {
  if (text == null) {
    return true;
  }
  if (text.length == 0) {
    return true;
  }
  return false;
}
