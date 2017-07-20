### Asset management

Since each of the targets that Monkey2 supports have their own way of managing files, Monkey2 provides an simple abstraction layer managing assets. This allows you to import and use images, files, fonts, and sounds in a consistent way, regardless of the target platform you are deploying to.

#### Importing Assets

Import assets for use in your project by using an Import directive.

```
'individual files
#Import "relative/local/path/to/your/file"

'entire folders
#Import "relaive/local/path/"
```

When importing entire folders, Make sure to include the trailing slash at the end to let the compiler know it's a folder.

For example, assuming a project structure like this:

```
main.monkey2
images/image1.jpg
images/image2.jpg
sounds/your_sound.wav
```

You could import your assets into main.monkey2 like so:

```
'main.monkey2

'import the entire images subfolder
#Import "images/"

'import a specific sound
#Import "sounds/your_sound.ogg"
```

These import directives can go anywhere in your source file, but standard practice is to put them at the top of the file.

#### Using Imported Assets

Once you've imported your assets, you can reference them by prefixing the imported filename with 'asset::'
This allows you to use them with an function or method that asks for a String path to a file.

```
#Import "images/spaceship.png"

Local myShipImage:Image = Image.Load("asset::spaceship.png")
```

If you imported a folder containing several assets, you can reference any of the assets in this way.

```
'assuming you have a folder called `data` containing an image named `image.jpg`, and an audio file `sound.ogg`:

#Import "data/"

Local image:Image = Image.Load("asset::image.jpg")
Local sound:Sound = Sound.Load("asset::sound.ogg")
```


#### Importing into a subfolder with "@/"

If you want to maintain a folder structure when importing, you can specify a target subfolder with `@/target/path/` after the path in the import directive.

```
#Import "images/image.jpg@/images/"
'imports image.jpg into a subfolder called images
```

`@/` also works when importing entire folders:

```
#Import "data/@/images/"
'imports everything from data/ into a subfolder called images/
```

When using the files in your code, make sure to add the target subfolder after `asset::`, for example:

```
#Import "images/spaceship.png@images/"

Local image:Image = Image.Load("asset::images/spaceship.png")
```
