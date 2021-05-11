# so the rate is i guess
# frequency / clock frequency * samples per phase


CLOCK_FREQ = 46875 # this is 48 MHz / 2^10
RATE_BITS = 16
NOTE_BITS = 7
SAMPLES_PER_PHASE = 2 ** RATE_BITS

def midi_note_to_freq(midi_note):
    return 440 * 2**((midi_note - 69)/12)

def freq_to_rate(freq):
    return int(freq / CLOCK_FREQ * SAMPLES_PER_PHASE)

for note in range(128):
    rate = freq_to_rate(midi_note_to_freq(note))
    print(f'        {RATE_BITS}d"{rate}" when {NOTE_BITS}d"{note}",')
print(f'        {RATE_BITS}d"0" when others;')
