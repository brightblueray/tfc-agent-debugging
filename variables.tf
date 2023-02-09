# General variables
variable "region" {
  type        = string
  description = "(required) The AWS region to use"
  default     = "us-east-2"
}

variable "prefix" {
  type        = string
  description = "prefix for searching AWS console"
  default     = "rryjewski"
}
