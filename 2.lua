local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local events = replicated_storage:WaitForChild("revents")
local orb_event = events:WaitForChild("orbevents")
local hoop_event = events:WaitForChild("hoopevent")
local rebirth_event = events:WaitForChild("rebirthevent")
