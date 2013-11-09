module DilicomApi
  class DilicomError < RuntimeError
  end
  class DilicomHttpError < DilicomError
  end
  class UnreadableMessageError < DilicomError
  end
  class DilicomStatusError < DilicomError
  end
end
