// IAudioService.aidl
package me.bradleygolden.Services.AudioService;

interface IAudioService {
    void playClip(String clip);
    void stopClip();
    void pauseClip();
    void resumeClip();
    boolean isPlaying();
    List<String> getTransactions();
    void clearTransactions();
}