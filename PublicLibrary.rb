#Use global variables to keep track of numbers
$book = 0
$unshelved = 0
$shelved = 0
$num_shelves = 0

require 'active_support/inflector' #To make module Pluralize work

module Pluralize #To help pluralizing strings
  def pluralize(count, string)
    "#{count} #{count < 2? string.singularize : string.pluralize}"
  end
end


class Library
  include Pluralize
  attr_accessor :shelves

  def initialize

    @shelves = []
    @booklist = []

  end

  def listShelves
    namelist = []

    shelves.each do |sf|
      namelist << sf.name
    end

    print "Library currently has #{pluralize($num_shelves, "shelf")}. The list is as follows: "  
    print namelist.to_s
  end

  def listBooks
    allbooklist = []

    ObjectSpace.each_object(Book) do |bk|
      allbooklist << bk.name
    end

    print "Library currently has #{pluralize(allbooklist.count, "book")}. The list is as follows: "  
    print allbooklist.sort.to_s
  end

end


class Shelf
  include Pluralize
  attr_accessor :list, :name

  def initialize(name, library)
    @list = []
    @name = name
    $num_shelves += 1
    library.shelves << self #Shelf is added to respective library @shelves
  end

  def addBook(book)
    $unshelved -= 1
    $shelved += 1
    list << book
    num_book = list.count
    puts "We just added book: #{book.name} to shelf: #{@name}"
    puts "Now shelf: #{@name} has #{pluralize(list.count, "book")}."
  end

  def dropBook(book)
    $shelved -= 1
    $unshelved += 1
    list.delete(book)
    list.count
    puts "We just dropped book: #{book.name} from shelf: #{@name}"
    puts "Now shelf: #{@name} has #{pluralize(list.count, "book")}."
  end

  def listBook #To show what books are currently on the shelf
    namelist = []

    list.each do |bk|
       namelist << bk.name
    end

    print "Shelf: #{@name} currently has #{pluralize(list.count, "book")}. The list is as follows: "  
    print namelist.to_s
  end

end

class Book

  attr_accessor :name, :status, :library

  def initialize(name, status="unshelved") #Each book has default status "unshelved"
    @name = name
    @status = status
    $book += 1
    $unshelved += 1
  end

  def unshelf #Drop book from shelf. Skip if book is unshelved
    if self.status == "unshelved"
      begin
        raise "***The book is not on a shelf!***"
      rescue
        puts "***#{self.name} is not on a shelf! This command has been skipped for your safety.***"
      end
      puts "***Now we will execute the next command***"
    else
      shelf = self.status
      shelf.dropBook(self)
      @status = "unshelved"
    end
  end

  def enshelf(shelf) #Add book to respective shelf
    if self.status == "unshelved"
      @status = shelf
      shelf.addBook(self)
    else
      self.unshelf
      shelf.addBook(self)
    end
  end

end


  aLibrary = Library.new
  aBook = Book.new("BookA")
  bBook = Book.new("BookB")
  cBook = Book.new("BookC")
  dBook = Book.new("BookD")
  aShelf = Shelf.new("ShelfA", aLibrary)
  bShelf = Shelf.new("ShelfB", aLibrary)
  puts "Current status of book #{aBook.name} is #{aBook.status}."
  puts "Current number of books is: #{$book}."
  aBook.enshelf(aShelf) #Class Book has method enshelf Q3
  bBook.enshelf(aShelf)
  cBook.enshelf(aShelf)
  dBook.enshelf(bShelf)
  puts aShelf.listBook #Each shelf knows what books it contains Q2
  puts bShelf.listBook
  puts "Current status of book: #{aBook.name} is on Shelf: #{aBook.status.name}."
  puts aLibrary.listShelves #Library knows the number of shelves it contains Q1
  aBook.unshelf #Class Book has method unsehlf Q3
  dBook.unshelf
  cBook.enshelf(bShelf) #Move cBook from aShelf to bShelf
  dBook.unshelf #Unshelf dBook again to show exception handling works
  puts "Current number of unshelved books is: #{$unshelved}."
  puts "Current number of shelved books is: #{$shelved}."
  puts aShelf.listBook
  puts bShelf.listBook
  puts "Current number of unshelved books is: #{$unshelved}." #
  puts aLibrary.listBooks #Library knows how many books it has and their names
