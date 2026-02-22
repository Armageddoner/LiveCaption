# LiveCaption
Utilized in ROBLOX, allows you higher functionality of the default Sound instance by adding more features 

The LiveCaption module is a utility designed for Roblox Luau to synchronize text captions (or specific function callbacks) with the TimePosition of a Sound instance. It is ideal for dialogue systems, boss theme lyrics.

# Constructor
`LiveCaption.new`
```luau
LiveCaption.new(Audio: Sound, CaptionCallback: (Caption: string) -> ()): LiveCaption
```

Creates a new LiveCaption object.

Audio: The Sound instance to track.

CaptionCallback: A function that runs whenever a time marker is reached. It receives the string defined in the marker as its first argument.

# Methods

`:CaptionTimePosition`
```luau
LiveCaption:CaptionTimePosition(TimePosition: number, Caption: string)
```
Registers a single caption to trigger at a specific `TimePosition` number in the `Sound`

TimePosition: The time in seconds (matching the Sound's TimePosition).

Caption: The string that will be passed to the callback function.
<hr>

`:Listen()`

```luau
LiveCaption:Listen()
```
Starts monitoring the audio's TimePosition.

Behavior: Uses `RunService.Heartbeat`. It automatically finds the nearest upcoming caption if the audio is already playing.

Looping: If the `Sound.Looped` property is true, the module will wait for the audio to restart and reset its internal index to the beginning.
<hr>

`:StopListening()`

```luau
LiveCaption:StopListening()
```
Disconnects the active listener. Use this to stop the caption tracking without destroying the object.

### notes:

this module will have updates in the future; it is currently in a primitive state.
