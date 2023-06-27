Config = {
  -- the park effect will turn off the brake lights after a random amount of time in seconds between parkTimerMin and parkTimerMax
  -- this is to simulate the vehicle being put in park after some time of being stopped
  enableParkEffect = true,
  parkTimerMin = 15, -- must be less than parkTimerMax (default 15)
  parkTimerMax = 60, -- must be greater than parkTimerMin (default 60)

  -- this is the speed at which the brake lights will turn off in MPH
  -- good values are beteween 3 - 20
  -- lower values will make the brake lights more responsive
  -- higher values can make a more realistic effect and reduce gap between braking and stopping
  brakeLightThreshold = 8, -- default 8
}